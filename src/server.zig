const std = @import("std");
const file_reader_lib = @import("file_reader.zig");
const http = std.http;
const content_identifier = @import("content_identifier.zig");
const anyGetHandler = @import("router/any_get_handler.zig");
const context = @import("context.zig");

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

                var ctx = context.Context.init(&request, rd);

                switch (ctx.request.head.method) {
                    .OPTIONS => {
                        ctx.respond("OK");
                        return ctx.handleResponse();
                    },
                    .GET => {},
                    else => {
                        return ctx.request.respond("", .{
                            .status = .NotFound,
                        });
                    },
                }
            }
        }
    }
};
