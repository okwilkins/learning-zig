const std = @import("std");

fn Node(comptime T: type) type {
    return struct {
        value: ?T,
        next: ?*Node = null,
        prev: ?*Node = null,
    };
}

var LinkedList = struct {};

fn main() void {
    const allocator = std.heap.GeneralPurposeAllocator(.{});
    LinkedList(isize).init(allocator);
}
