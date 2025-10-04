const std = @import("std");
const zigsh = @import("zigsh");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var arguments = try std.process.argsWithAllocator(allocator);

    var host: []const u8 = "127.0.0.1";
    var port: u16 = 8080;
    var folder: []const u8 = "";
    // Skip first argument (program name)
    _ = arguments.skip();
    while (arguments.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h")) {
            host = arguments.next().?;
        } else if (std.mem.eql(u8, arg, "-p")) {
            port = try std.fmt.parseInt(u16, arguments.next().?, 10);
        } else if (std.mem.eql(u8, arg, "-f")) {
            folder = arguments.next().?;
        } else {
            std.debug.print("Invalid argument: {s}\n", .{arg});
            return error.InvalidArgument;
        }
    }

    zigsh.Server(allocator, host, port, folder) catch |err| {
        switch (err) {
            .FolderNotFound => std.log.err("Folder not found: {}", .{err}),
            .AccessDenied => std.log.err("Access denied: {}", .{err}),
            .NotDir => std.log.err("Not a directory: {}", .{err}),
            .FileNotFound => std.log.err("File not found: {}", .{err}),
            else => std.log.err("Failed to start server: {}", .{err}),
        }
        return err;
    };
}
