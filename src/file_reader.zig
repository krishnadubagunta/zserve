const std = @import("std");

pub const FileReader = struct {
    path: []const u8,
    allocator: std.mem.Allocator,
    file_list: std.StringHashMap(*std.fs.File),

    pub fn init(path: []const u8, allocator: std.mem.Allocator) !FileReader {
        var file_list = std.StringHashMap(*std.fs.File).init(allocator);

        var dir = try std.fs.cwd().openDir(path, .{ .iterate = true, .access_sub_paths = true });
        defer dir.close();

        var dir_iterator = dir.iterate();
        while (try dir_iterator.next()) |entry| {
            if (entry.kind == .file) {
                // duplicate name, since entry.name is temporary
                const name_copy = try allocator.dupe(u8, entry.name);
                const file = try allocator.create(std.fs.File);
                file.* = dir.openFile(entry.name, .{ .mode = .read_only }) catch |err| {
                    std.log.err("Failed to open file '{s}': {s}", .{ entry.name, @errorName(err) });
                    return err;
                };
                try file_list.put(name_copy, file);
            }
        }

        return FileReader{
            .path = path,
            .allocator = allocator,
            .file_list = file_list,
        };
    }

    pub fn get_file(self: *FileReader, relative_path: []const u8) error{FileNotFound}!*std.fs.File {
        if (self.file_list.get(relative_path)) |file_ptr| {
            return file_ptr;
        } else {
            return error.FileNotFound;
        }
    }

    pub fn readFile(self: *FileReader, file: *std.fs.File) ![]u8 {
        const file_size = try file.getEndPos();
        const buffer = try self.allocator.alloc(u8, file_size);
        _ = try file.readAll(buffer);
        try file.seekTo(0);
        return buffer;
    }

    pub fn deinit(self: *FileReader) void {
        var it = self.file_list.valueIterator();
        while (it.next()) |file_ptr| {
            file_ptr.*.close();
        }
        self.file_list.deinit();
    }
};
