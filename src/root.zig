//! By convention, root.zig is the root source file when making a library.
const server = @import("server.zig");
const std = @import("std");
const file_reader = @import("file_reader.zig");

pub fn Server(allocator: std.mem.Allocator, host: []const u8, port: u16, folder: []const u8) !void {
    var serve = server.Server.Init(allocator, host, port);
    var reader = file_reader.FileReader.init(folder, allocator) catch |err| {
        std.log.err("Failed to initialize file reader: {}", .{err});
        return;
    };
    defer reader.deinit();

    serve.start(&reader) catch |err| {
        switch (err) {
            error.InvalidAddress => {
                std.log.err("Invalid address: {}", .{err});
            },
            else => {
                std.log.err("Failed to start server: {}", .{err});
            },
        }
    };
}
