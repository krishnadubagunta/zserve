const std = @import("std");
const file_reader_lib = @import("file_reader.zig");
const http = std.http;
const content_identifier = @import("content_identifier.zig");

pub const Server = struct {
    allocator: std.mem.Allocator,
    host: []const u8,
    port: u16,

    pub fn Init(allocator: std.mem.Allocator, host: []const u8, port: u16) Server {
        return Server{
            .allocator = allocator,
            .host = host,
            .port = port,
        };
    }

    pub fn start(self: *Server, rd: *file_reader_lib.FileReader) !void {
        const addr = std.net.Address.parseIp(self.host, self.port) catch |err| {
            std.log.err("Failed to parse IP address: {}", .{err});
            return error.InvalidAddress;
        };
        var listener = addr.listen(.{ .reuse_address = true }) catch |err| {
            std.log.err("Failed to listen on address: {}", .{err});
            return error.ListenFailed;
        };
        defer listener.deinit();

        while (true) {
            const connection = listener.accept() catch |err| {
                std.log.err("Failed to accept connection: {}", .{err});
                continue;
            };
            var reader_buffer: [8192]u8 = undefined;
            var writer_buffer: [8192]u8 = undefined;

            var file_reader = connection.stream.reader(&reader_buffer);
            const reader = &file_reader.file_reader.interface;
            var file_writer = connection.stream.writer(&writer_buffer);
            const writer = &file_writer.file_writer.interface;

            var server = http.Server.init(reader, writer);

            while (true) {
                var request = server.receiveHead() catch |err| {
                    if (err == error.HttpConnectionClosing) break; // client closed connection
                    std.log.err("Failed to receive HTTP request: {}", .{err});
                    break;
                };

                switch (request.head.method) {
                    .GET => {
                        var token_file_name = std.mem.tokenizeAny(u8, request.head.target, "/");
                        const file_name: []const u8 = token_file_name.next() orelse "index.html";
                        const file = rd.get_file(file_name) catch |err| {
                            std.log.err("Failed to get file: {}, with file name: {s}", .{ err, file_name });
                            try request.respond("Not found", .{ .status = .not_found });
                            break;
                        };
                        const contentType = content_identifier.contentType(file_name);
                        const buffer = rd.readFile(file) catch |err| {
                            std.log.err("Failed to read file: {}, with file name: {s}", .{ err, file_name });
                            try request.respond("Not found", .{ .status = .not_found });
                            break;
                        };
                        request.respond(buffer, .{
                            .status = .ok,
                            .extra_headers = &.{
                                .{ .name = "Content-Type", .value = contentType },
                                // .{ .name = "Content-Length", .value = try std.fmt.allocPrint(self.allocator, "{}", .{file_size}) }, .{ .name = "Cache-Control", .value = "max-age=3600" }
                            },
                        }) catch |err| {
                            std.log.err("Failed to respond to HTTP request: {}", .{err});
                            break;
                        };
                        std.heap.page_allocator.free(buffer);
                    },
                    else => {
                        std.log.warn("Unsupported method: {any}", .{request.head.method});
                        request.respond("Method not allowed", .{ .status = .method_not_allowed }) catch |err| {
                            std.log.err("Failed to respond to HTTP request: {}", .{err});
                        };
                    },
                }
            }
        }
    }
};
