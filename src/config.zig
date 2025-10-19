const CompressionStrategy = enum {
    Gzip,
    Deflate,
};

const RouterConfig = struct {
    root: []const u8,
};

const Compression = struct {
    enable: bool,
    level: u8,
    strategy: CompressionStrategy,
};

const Cache = struct {
    enabled: bool,
    all: bool,
    paths: []const []const u8,
    max_entries: usize,
    max_size: usize,
};

pub const Config = struct {
    compression: Compression,
    cache: Cache,
    router: RouterConfig,
};
