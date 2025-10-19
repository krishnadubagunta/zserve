const context = @import("context.zig");
const HandlerFn = fn (ctx: *context.Context) void;

pub const MiddlewareConstruct = struct {
    handler: HandlerFn,
    next: ?*MiddlewareConstruct,

    fn init(handler: HandlerFn, next: ?*MiddlewareConstruct) MiddlewareConstruct {
        return MiddlewareConstruct{
            .handler = handler,
            .next = next,
        };
    }
};
