module school_org::membership_badge {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::event;
    use sui::table::{Self, Table};
    
    /// One-Time Witness for module initialization
    struct MEMBERSHIP_BADGE has drop {}
    
    /// The main membership badge NFT
    struct MembershipBadge has key, store {
        id: UID,
        email_domain: String,        // e.g., "@university.edu"
        organization: String,         // e.g., "University Name"
        issued_at: u64,
        holder_address: address,     // The zkLogin address
    }

    /// Registry to track issued badges and prevent duplicates
    struct BadgeRegistry has key {
        id: UID,
        // Maps zkLogin-derived address to their badge ID
        verified_addresses: Table<address, address>,
        // Whitelist of allowed email domains
        allowed_domains: Table<String, bool>,
        admin: address,
    }

    /// Admin capability for managing the system
    struct AdminCap has key {
        id: UID,
    }

    // ====== Events ======
    
    struct MemberRegistered has copy, drop {
        badge_id: address,
        member_address: address,
        email_domain: String,
        organization: String,
        timestamp: u64,
    }

    struct BadgeVerified has copy, drop {
        badge_id: address,
        holder_address: address,
        is_valid: bool,
    }

    struct DomainAdded has copy, drop {
        domain: String,
    }

    struct DomainRemoved has copy, drop {
        domain: String,
    }

    struct MembershipRevoked has copy, drop {
        member_address: address,
        badge_id: address,
    }

    // ====== Errors ======
    
    const ENotAdmin: u64 = 1;
    const EAlreadyRegistered: u64 = 2;
    const EInvalidBadge: u64 = 3;
    const EDomainNotAllowed: u64 = 4;
    const EDomainAlreadyExists: u64 = 5;

    // ====== Init Function ======
    
    /// Initialize the module - called once when published
    fun init(_otw: MEMBERSHIP_BADGE, ctx: &mut TxContext) {
        let registry = BadgeRegistry {
            id: object::new(ctx),
            verified_addresses: table::new(ctx),
            allowed_domains: table::new(ctx),
            admin: tx_context::sender(ctx),
        };
        
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };
        
        transfer::share_object(registry);
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

    // ====== Admin Functions ======
    
    /// Add an allowed email domain (admin only)
    /// Example: "@university.edu", "@college.ph"
    public entry fun add_allowed_domain(
        _admin_cap: &AdminCap,
        registry: &mut BadgeRegistry,
        domain: vector<u8>,
        _ctx: &mut TxContext
    ) {
        let domain_str = string::utf8(domain);
        
        // Check if domain already exists
        assert!(
            !table::contains(&registry.allowed_domains, domain_str),
            EDomainAlreadyExists
        );
        
        table::add(&mut registry.allowed_domains, domain_str, true);
        
        event::emit(DomainAdded {
            domain: domain_str,
        });
    }

    /// Remove an allowed email domain (admin only)
    public entry fun remove_allowed_domain(
        _admin_cap: &AdminCap,
        registry: &mut BadgeRegistry,
        domain: vector<u8>,
        _ctx: &mut TxContext
    ) {
        let domain_str = string::utf8(domain);
        table::remove(&mut registry.allowed_domains, domain_str);
        
        event::emit(DomainRemoved {
            domain: domain_str,
        });
    }

    /// Revoke membership from a specific address (admin only)
    public entry fun revoke_membership(
        _admin_cap: &AdminCap,
        registry: &mut BadgeRegistry,
        member_address: address,
        _ctx: &mut TxContext
    ) {
        if (table::contains(&registry.verified_addresses, member_address)) {
            let badge_id = *table::borrow(&registry.verified_addresses, member_address);
            table::remove(&mut registry.verified_addresses, member_address);
            
            event::emit(MembershipRevoked {
                member_address,
                badge_id,
            });
        };
    }

    // ====== Public Functions ======
    
    /// Register as a member using zkLogin and receive an NFT badge
    /// 
    /// HOW IT WORKS:
    /// 1. Student authenticates with Google OAuth (via your webapp)
    /// 2. Your webapp gets their zkLogin-derived Sui address
    /// 3. Student calls this function from their zkLogin wallet
    /// 4. Smart contract validates their email domain
    /// 5. NFT badge is automatically minted to their address
    /// 
    /// This is SELF-SERVICE - students register themselves after zkLogin auth
    public entry fun register_member(
        registry: &mut BadgeRegistry,
        email_domain: vector<u8>,       // e.g., "@dlsu.edu.ph"
        organization: vector<u8>,        // e.g., "De La Salle University"
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let email_domain_str = string::utf8(email_domain);
        
        // Verify the email domain is whitelisted
        assert!(
            table::contains(&registry.allowed_domains, email_domain_str),
            EDomainNotAllowed
        );
        
        // Check if this address is already registered
        assert!(
            !table::contains(&registry.verified_addresses, sender),
            EAlreadyRegistered
        );
        
        // Create the membership badge NFT
        let badge = MembershipBadge {
            id: object::new(ctx),
            email_domain: email_domain_str,
            organization: string::utf8(organization),
            issued_at: tx_context::epoch(ctx),
            holder_address: sender,
        };
        
        let badge_id = object::uid_to_address(&badge.id);
        
        // Register the member in the registry
        table::add(&mut registry.verified_addresses, sender, badge_id);
        
        // Emit registration event
        event::emit(MemberRegistered {
            badge_id,
            member_address: sender,
            email_domain: email_domain_str,
            organization: string::utf8(organization),
            timestamp: tx_context::epoch(ctx),
        });
        
        // Transfer badge to the member
        transfer::transfer(badge, sender);
    }

    /// Alternative: Admin registers member and issues badge
    /// Use this if you want admin control over registration
    public entry fun register_member_admin(
        _admin_cap: &AdminCap,
        registry: &mut BadgeRegistry,
        member_address: address,         // Member's zkLogin address
        email_domain: vector<u8>,
        organization: vector<u8>,
        ctx: &mut TxContext
    ) {
        let email_domain_str = string::utf8(email_domain);
        
        // Verify the email domain is whitelisted
        assert!(
            table::contains(&registry.allowed_domains, email_domain_str),
            EDomainNotAllowed
        );
        
        // Check if this address is already registered
        assert!(
            !table::contains(&registry.verified_addresses, member_address),
            EAlreadyRegistered
        );
        
        // Create the membership badge NFT
        let badge = MembershipBadge {
            id: object::new(ctx),
            email_domain: email_domain_str,
            organization: string::utf8(organization),
            issued_at: tx_context::epoch(ctx),
            holder_address: member_address,
        };
        
        let badge_id = object::uid_to_address(&badge.id);
        
        // Register the member in the registry
        table::add(&mut registry.verified_addresses, member_address, badge_id);
        
        // Emit registration event
        event::emit(MemberRegistered {
            badge_id,
            member_address,
            email_domain: email_domain_str,
            organization: string::utf8(organization),
            timestamp: tx_context::epoch(ctx),
        });
        
        // Transfer badge to the member
        transfer::transfer(badge, member_address);
    }

    // ====== Verification Functions ======
    
    /// Verify if a badge is valid and belongs to the claimed address
    public fun verify_badge(
        badge: &MembershipBadge,
        registry: &BadgeRegistry,
        claimed_address: address,
    ): bool {
        let badge_id = object::uid_to_address(&badge.id);
        
        // Check if the address is registered and the badge ID matches
        if (table::contains(&registry.verified_addresses, claimed_address)) {
            let registered_badge_id = *table::borrow(&registry.verified_addresses, claimed_address);
            registered_badge_id == badge_id
        } else {
            false
        }
    }

    /// Verify badge and emit verification event
    public entry fun verify_and_emit(
        badge: &MembershipBadge,
        registry: &BadgeRegistry,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let is_valid = verify_badge(badge, registry, sender);
        let badge_id = object::uid_to_address(&badge.id);
        
        event::emit(BadgeVerified {
            badge_id,
            holder_address: sender,
            is_valid,
        });
    }

    // ====== Getter Functions ======
    
    /// Get the email domain from a badge (e.g., "@university.edu")
    public fun get_email_domain(badge: &MembershipBadge): String {
        badge.email_domain
    }

    /// Get the organization name from a badge
    public fun get_organization(badge: &MembershipBadge): String {
        badge.organization
    }

    /// Get the timestamp when badge was issued
    public fun get_issued_at(badge: &MembershipBadge): u64 {
        badge.issued_at
    }

    /// Get the holder's address from a badge
    public fun get_holder_address(badge: &MembershipBadge): address {
        badge.holder_address
    }

    /// Check if an address is registered as a member
    public fun is_member_registered(
        registry: &BadgeRegistry,
        addr: address
    ): bool {
        table::contains(&registry.verified_addresses, addr)
    }

    /// Check if a domain is allowed for registration
    public fun is_domain_allowed(
        registry: &BadgeRegistry,
        domain: String
    ): bool {
        table::contains(&registry.allowed_domains, domain)
    }

    /// Get badge ID for a registered member
    public fun get_member_badge_id(
        registry: &BadgeRegistry,
        addr: address
    ): address {
        *table::borrow(&registry.verified_addresses, addr)
    }
}
