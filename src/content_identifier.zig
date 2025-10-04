const std = @import("std");

const MimeEntry = struct { ext: []const u8, mime: []const u8 };

const mime_table = [_]MimeEntry{
    .{ .ext = ".html", .mime = "text/html" },
    .{ .ext = ".css", .mime = "text/css" },
    .{ .ext = ".js", .mime = "application/javascript" },
    .{ .ext = ".json", .mime = "application/json" },
    .{ .ext = ".png", .mime = "image/png" },
    .{ .ext = ".jpg", .mime = "image/jpeg" },
    .{ .ext = ".jpeg", .mime = "image/jpeg" },
    .{ .ext = ".gif", .mime = "image/gif" },
    .{ .ext = ".svg", .mime = "image/svg+xml" },
    .{ .ext = ".ico", .mime = "image/x-icon" },
    .{ .ext = ".txt", .mime = "text/plain" },
    .{ .ext = ".wasm", .mime = "application/wasm" },
    .{ .ext = ".webp", .mime = "image/webp" },
    .{ .ext = ".mp4", .mime = "video/mp4" },
    .{ .ext = ".mp3", .mime = "audio/mpeg" },
};

pub fn contentType(path: []const u8) []const u8 {
    const ext = std.fs.path.extension(path);
    for (mime_table) |entry| {
        if (std.mem.eql(u8, ext, entry.ext)) return entry.mime;
    }
    return "application/octet-stream";
}
