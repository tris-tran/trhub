const str = @import("std");

pub fn validate(comptime TRPC: type) void {
    const tInfo = @typeInfo(TRPC);

    if (tInfo != .Struct) @compileError("Expected struct");
}
