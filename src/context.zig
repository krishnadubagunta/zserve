const std = @import("std");
const http = std.http;
const FileReader = @import("file_reader.zig");
const middlewares = @import("middlewares/middleware.zig");
const content_identifier = @import("content_identifier.zig");

const Context = struct {
    allocator: std.mem.Allocator,
    request: http.Server.Request,
    reader: FileReader,
    status: http.Status,
    body: []const u8,
    headers: []http.Header,
    handlers: []*middlewares.MiddlewareConstruct,

    pub fn respond(self: *Context, content: []const u8) !void {
        self.body = content;
    }

    pub fn add_header(self: *Context, name: []const u8, value: []const u8) void {
        self.headers.append(self.allocator, .{ .name = name, .value = value });
    }

    pub fn handleResponse(self: *Context) !void {
        try self.request.respond(self.body, .{
            .status = self.status or http.Status.accepted,
            .extra_headers = self.headers,
        });
    }

    pub fn handle(self: *Context) !void {
        try self.handleResponse();
    }

    fn init(allocator: std.mem.Allocator, request: *http.Server.Request, reader: *FileReader, handlers: []*middlewares.MiddlewareConstruct) Context {
        const headers = std.ArrayList(http.Header).initCapacity(allocator, 1);

        return Context{
            .allocator = allocator,
            .request = request,
            .reader = reader,
            .status = http.Status.accepted,
            .handlers = handlers,
            .headers = headers,
            .body = "",
        };
    }
};
