// School Organization Membership Badge NFT Contract
// File: sources/membership_badge.move

module school_org::membership_badge {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::event;
    use sui::table::{Self, Table};

    // ====== Structs ======
    
    /// The main membership badge NFT
    struct MembershipBadge has key, store {
        id: UID,
        name: String,
        program: String,
        student_number: String,
        issued_at: u64,
        organization: String,
    }

    /// Registry to track issued badges and prevent duplicates
    struct BadgeRegistry has key {
        id: UID,
        student_numbers: Table<String, address>,
        admin: address,
    }

    /// One-time capability for initializing the registry
    struct AdminCap has key {
        id: UID,
    }

    // ====== Events ======
    
    struct BadgeIssued has copy, drop {
        badge_id: address,
        recipient: address,
        student_number: String,
        name: String,
        program: String,
    }

    struct BadgeVerified has copy, drop {
        badge_id: address,
        student_number: String,
        is_valid: bool,
    }

    // ====== Errors ======
    
    const ENotAdmin: u64 = 1;
    const EStudentNumberExists: u64 = 2;
    const EInvalidBadge: u64 = 3;

    // ====== Init Function ======
    
    /// Initialize the module - called once when published
    fun init(ctx: &mut TxContext) {
        let registry = BadgeRegistry {
            id: object::new(ctx),
            student_numbers: table::new(ctx),
            admin: tx_context::sender(ctx),
        };
        
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };
        
        transfer::share_object(registry);
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

    // ====== Public Functions ======
    
    /// Issue a new membership badge (admin only)
    public entry fun issue_badge(
        _admin_cap: &AdminCap,
        registry: &mut BadgeRegistry,
        recipient: address,
        name: vector<u8>,
        program: vector<u8>,
        student_number: vector<u8>,
        organization: vector<u8>,
        ctx: &mut TxContext
    ) {
        let student_number_str = string::utf8(student_number);
        
        // Check if student number already exists
        assert!(!table::contains(&registry.student_numbers, student_number_str), EStudentNumberExists);
        
        // Create the badge
        let badge = MembershipBadge {
            id: object::new(ctx),
            name: string::utf8(name),
            program: string::utf8(program),
            student_number: student_number_str,
            issued_at: tx_context::epoch(ctx),
            organization: string::utf8(organization),
        };
        
        let badge_id = object::uid_to_address(&badge.id);
        
        // Register the student number
        table::add(&mut registry.student_numbers, student_number_str, badge_id);
        
        // Emit event
        event::emit(BadgeIssued {
            badge_id,
            recipient,
            student_number: student_number_str,
            name: string::utf8(name),
            program: string::utf8(program),
        });
        
        // Transfer badge to recipient
        transfer::transfer(badge, recipient);
    }

    /// Verify if a badge is valid
    public fun verify_badge(
        badge: &MembershipBadge,
        registry: &BadgeRegistry,
    ): bool {
        let badge_id = object::uid_to_address(&badge.id);
        
        // Check if student number exists in registry
        if (table::contains(&registry.student_numbers, badge.student_number)) {
            let registered_id = *table::borrow(&registry.student_numbers, badge.student_number);
            registered_id == badge_id
        } else {
            false
        }
    }

    /// Public entry function to emit verification event
    public entry fun verify_and_emit(
        badge: &MembershipBadge,
        registry: &BadgeRegistry,
    ) {
        let is_valid = verify_badge(badge, registry);
        let badge_id = object::uid_to_address(&badge.id);
        
        event::emit(BadgeVerified {
            badge_id,
            student_number: badge.student_number,
            is_valid,
        });
    }

    // ====== Getter Functions ======
    
    public fun get_name(badge: &MembershipBadge): String {
        badge.name
    }

    public fun get_program(badge: &MembershipBadge): String {
        badge.program
    }

    public fun get_student_number(badge: &MembershipBadge): String {
        badge.student_number
    }

    public fun get_organization(badge: &MembershipBadge): String {
        badge.organization
    }

    public fun get_issued_at(badge: &MembershipBadge): u64 {
        badge.issued_at
    }

    /// Check if student number is registered
    public fun is_student_registered(
        registry: &BadgeRegistry,
        student_number: String
    ): bool {
        table::contains(&registry.student_numbers, student_number)
    }
}
