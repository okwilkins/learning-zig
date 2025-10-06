const std = @import("std");
const Allocator = std.mem.Allocator;

fn Node(comptime T: type) type {
    return struct {
        value: T,
        next: ?*Node(T) = null,
    };
}

fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        head: ?*Node(T) = null,
        tail: ?*Node(T) = null,
        len: usize = 0,
        allocator: Allocator,

        fn init(allocator: Allocator) Self {
            return Self{ .allocator = allocator };
        }

        fn deinit(self: *Self) void {
            if (self.head == null) return;
            var current = self.head;

            while (current) |node| {
                const next = node.next;
                self.allocator.destroy(node);
                current = next;
            }
        }

        fn enqueue(self: *Self, value: T) !void {
            const new_tail = try self.allocator.create(Node(T));
            new_tail.* = .{ .value = value, .next = null };

            if (self.head == null) self.head = new_tail;
            if (self.tail) |tail| {
                tail.next = new_tail;
            }
            self.tail = new_tail;
            self.len += 1;
        }

        fn deque(self: *Self) ?T {
            const head = self.head orelse return null;
            const value = head.value;

            self.head = head.next;
            self.allocator.destroy(head);
            self.len -= 1;

            if (self.len == 0) {
                self.tail = null;
            }

            return value;
        }

        fn peek(self: *const Self) ?T {
            if (self.head) |head| {
                return head.value;
            } else {
                return null;
            }
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Memory leaked!");
    }

    var queue = Queue(usize).init(allocator);
    defer queue.deinit();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        try queue.enqueue(i);
    }

    std.debug.print("Length: {d}\n", .{queue.len});

    while (queue.deque()) |value| {
        std.debug.print("Deqeued value: {d}\n", .{value});
    }

    std.debug.print("Length: {d}\n", .{queue.len});
}
