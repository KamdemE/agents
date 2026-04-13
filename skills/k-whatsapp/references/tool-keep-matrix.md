# WhatsApp MCP Tool Keep Matrix

| Tool | Necessary (YES/NO) | Justification |
|---|---|---|
| analytics_chat_insights | NO | Nice analytics, not core triage/send flow |
| analytics_overview | NO | Not required for operational workflows |
| analytics_search | NO | Redundant for daily usage |
| analytics_timeline | NO | Timeline analytics not essential |
| analytics_top_chats | NO | Ranking chats not needed |
| batch_send_text | NO | Risky bulk send; rare intent |
| check_phone_number | YES | Needed for JID/contact validation |
| cleanup_media | NO | Housekeeping only |
| connection_status | YES | Mandatory connectivity preflight |
| create_channel | NO | Channel management not core routine |
| create_group | NO | Group creation rarely needed |
| daily_digest | YES | Useful high-level pass for what's up |
| delete_channel | YES | Explicitly requested to keep |
| delete_message | NO | Destructive, rarely needed |
| download_media | YES | Needed when media context matters |
| edit_message | YES | Explicitly requested to keep |
| find_messages | YES | Cross-chat investigation for threads |
| forward_message | YES | Explicitly requested to keep |
| get_business_profile | NO | Business metadata not needed |
| get_channel_info | NO | Channel admin scope |
| get_contact_info | YES | Core target verification |
| get_group_info | YES | Explicitly requested to keep |
| get_messages | YES | Primary read tool in skill usage |
| get_messages_multi | NO | Optional convenience |
| get_profile_picture | NO | Cosmetic lookup |
| leave_group | NO | Rare governance action |
| list_chats | YES | Core unread/priority overview |
| list_contacts | YES | Contact discovery for targeting |
| list_groups | YES | Explicitly requested to keep |
| manage_block | NO | Rare moderation task |
| manage_channel | NO | Channel admin not core |
| manage_chat | YES | Needed for closure hygiene (archive 1:1) |
| manage_chat_label | NO | Labeling optional |
| manage_contact_tags | NO | Tagging optional |
| manage_group_invite | NO | Group admin not core |
| manage_group_participants | NO | Group admin not core |
| manage_label | NO | Label taxonomy optional |
| manage_message_label | NO | Optional metadata |
| manage_privacy | NO | Account admin, not regular intent |
| manage_watchlist | NO | Optional monitoring feature |
| read_messages | YES | Explicitly requested to keep |
| search_messages | YES | Essential query fallback |
| send_audio | NO | Low-frequency send type |
| send_contact | NO | Rare send type |
| send_document | YES | Useful for document sharing |
| send_image | YES | Useful for practical interactions |
| send_location | NO | Rare use |
| send_poll | NO | Rare use |
| send_presence | NO | Presence control not needed |
| send_reaction | NO | Nice-to-have only |
| send_sticker | NO | Non-essential |
| send_text | YES | Primary outbound action |
| send_video | NO | Low-frequency/heavy |
| set_disappearing | NO | Policy/admin feature |
| set_group_picture | NO | Group admin only |
| star_message | NO | Optional bookmarking |
| update_about | NO | Profile admin only |
| update_channel | NO | Channel admin only |
| update_display_name | NO | Profile admin only |
| update_group_description | NO | Group admin only |
| update_group_settings | NO | Group admin only |
| update_group_subject | NO | Group admin only |
| update_profile_picture | NO | Profile admin only |
| whatsapp_guide | YES | Tool bootstrap reference |
| whatsup | YES | Direct fit to recurring digest use |
