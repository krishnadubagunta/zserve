const context = @import("context.zig");
const std = @import("std");
const content_identifier = @import("content_identifier.zig");

fn handle(ctx: *context.Context) void {
    var token_file_name = std.mem.tokenizeAny(u8, ctx.request.head.target, "/");
    const file_name: []const u8 = token_file_name.next() orelse "index.html";
    const file = ctx.rd.get_file(file_name) catch |err| {
        std.log.err("Failed to get file: {}, with file name: {s}", .{ err, file_name });
        try ctx.request.respond("Not found", .{ .status = .not_found });
        return;
    };
    const contentType = content_identifier.contentType(file_name);
    const buffer = ctx.rd.readFile(file) catch |err| {
        std.log.err("Failed to read file: {}, with file name: {s}", .{ err, file_name });
        try ctx.request.respond("Not found", .{ .status = .not_found });
        return;
    };
    defer std.heap.page_allocator.free(buffer);

    ctx.request.respond(buffer, .{
        .status = .ok,
        .extra_headers = &.{
            .{ .name = "Content-Type", .value = contentType },
        },
    }) catch |err| {
        std.log.err("Failed to respond to HTTP request: {}", .{err});
        return;
    };
}
