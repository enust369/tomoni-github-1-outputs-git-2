const env = window.__TOMONI_ENV__ || {};
const supabaseUrl = env.VITE_SUPABASE_URL || "https://qporjswbpfjfsnxequyd.supabase.co";
const supabaseAnonKey = env.VITE_SUPABASE_ANON_KEY || "sb_publishable_JCk0iNVL30Kmgih4hknwug_Wj0sidGw";
const configured = Boolean(supabaseUrl && supabaseAnonKey);
const client = configured
  ? (await import("https://esm.sh/@supabase/supabase-js@2")).createClient(supabaseUrl, supabaseAnonKey)
  : null;

const notConfigured = () => ({
  data: null,
  error: new Error("Supabaseの接続情報が設定されていません。"),
});

window.tomoniAuth = {
  configured,
  signUp: (email, password) => client
    ? client.auth.signUp({ email, password })
    : Promise.resolve(notConfigured()),
  signIn: (email, password) => client
    ? client.auth.signInWithPassword({ email, password })
    : Promise.resolve(notConfigured()),
  signOut: () => client
    ? client.auth.signOut()
    : Promise.resolve(notConfigured()),
  getUser: () => client
    ? client.auth.getUser()
    : Promise.resolve(notConfigured()),
  getSession: () => client
    ? client.auth.getSession()
    : Promise.resolve(notConfigured()),
  resetPassword: (email) => client
    ? client.auth.resetPasswordForEmail(email, { redirectTo: window.location.href.split("#")[0] })
    : Promise.resolve(notConfigured()),
  updatePassword: (password) => client
    ? client.auth.updateUser({ password })
    : Promise.resolve(notConfigured()),
  onAuthStateChange: (callback) => client
    ? client.auth.onAuthStateChange(callback)
    : { data: { subscription: { unsubscribe: () => {} } } },
  listListings: () => client
    ? client.from("listings").select("*").order("created_at", { ascending: false })
    : Promise.resolve(notConfigured()),
  listProfiles: () => client
    ? client.from("profiles").select("user_id,nickname,age,gender,area,photo_urls,personality_title,personality_tags,is_verified")
    : Promise.resolve(notConfigured()),
  getListing: (id) => client
    ? client.from("listings").select("*").eq("id", id).single()
    : Promise.resolve(notConfigured()),
  createListing: (listing) => client
    ? client.from("listings").insert(listing).select().single()
    : Promise.resolve(notConfigured()),
  updateListing: (id, listing) => client
    ? client.from("listings").update(listing).eq("id", id).select().single()
    : Promise.resolve(notConfigured()),
  deleteListing: (id) => client
    ? client.from("listings").delete().eq("id", id)
    : Promise.resolve(notConfigured()),
  listFavorites: () => client
    ? client.from("favorites").select("*").order("created_at", { ascending: false })
    : Promise.resolve(notConfigured()),
  addFavorite: (favorite) => client
    ? client.from("favorites").insert(favorite).select().single()
    : Promise.resolve(notConfigured()),
  removeFavorite: (listingId, targetUserId = null) => {
    if (!client) return Promise.resolve(notConfigured());
    const filters = [`listing_id.eq.${listingId}`];
    if (targetUserId) filters.push(`target_user_id.eq.${targetUserId}`);
    return client.from("favorites").delete().or(filters.join(","));
  },
  createReport: (report) => {
    if (!client) return Promise.resolve(notConfigured());
    const payload = Object.fromEntries(Object.entries(report).filter(([, value]) => value !== undefined && value !== null && value !== ""));
    return client.from("reports").insert(payload).select().single();
  },
  createContact: (contact) => {
    if (!client) return Promise.resolve(notConfigured());
    const payload = Object.fromEntries(Object.entries(contact).filter(([, value]) => value !== undefined && value !== null && value !== ""));
    return client.from("contacts").insert(payload).select().single();
  },
  listBlocks: () => client
    ? client.from("blocks").select("*").order("created_at", { ascending: false })
    : Promise.resolve(notConfigured()),
  createBlock: (block) => client
    ? client.from("blocks").upsert(block, { onConflict: "blocker_id,blocked_user_id" }).select().single()
    : Promise.resolve(notConfigured()),
  removeBlock: (blockedUserId) => client
    ? client.from("blocks").delete().eq("blocked_user_id", blockedUserId)
    : Promise.resolve(notConfigured()),
  getAdminSummary: () => client
    ? client.rpc("get_admin_summary")
    : Promise.resolve(notConfigured()),
  listAdminUsers: (searchTerm = "") => client
    ? client.rpc("get_admin_users", { search_term: searchTerm })
    : Promise.resolve(notConfigured()),
  listAdminReports: () => client
    ? client.rpc("get_admin_reports")
    : Promise.resolve(notConfigured()),
  listAdminListings: () => client
    ? client.rpc("get_admin_listings")
    : Promise.resolve(notConfigured()),
  listAdminBlocks: () => client
    ? client.rpc("get_admin_blocks")
    : Promise.resolve(notConfigured()),
  listAdminContacts: () => client
    ? client.rpc("get_admin_contacts")
    : Promise.resolve(notConfigured()),
  resolveAdminReport: (reportId) => client
    ? client.rpc("resolve_admin_report", { target_report_id: reportId })
    : Promise.resolve(notConfigured()),
  endAdminListing: (listingId) => client
    ? client.rpc("admin_end_listing", { target_listing_id: listingId })
    : Promise.resolve(notConfigured()),
  deleteAdminListing: (listingId) => client
    ? client.rpc("admin_delete_listing", { target_listing_id: listingId })
    : Promise.resolve(notConfigured()),
  unblockAdminUser: (blockId) => client
    ? client.rpc("admin_unblock_user", { target_block_id: blockId })
    : Promise.resolve(notConfigured()),
  resolveAdminContact: (contactId) => client
    ? client.rpc("resolve_admin_contact", { target_contact_id: contactId })
    : Promise.resolve(notConfigured()),
  hasBlockRelation: (targetUserId) => client
    ? client.rpc("has_block_relation", { p_target_user_id: targetUserId })
    : Promise.resolve(notConfigured()),
  listMatches: () => client
    ? client.from("matches").select("*").eq("status", "active").order("created_at", { ascending: false })
    : Promise.resolve(notConfigured()),
  getMatchWithUser: (userId) => client
    ? client.from("matches").select("*").eq("status", "active").or(`user1_id.eq.${userId},user2_id.eq.${userId}`).maybeSingle()
    : Promise.resolve(notConfigured()),
  ensureMatchWithUser: (userId) => client
    ? client.rpc("ensure_match_with_user", { p_target_user_id: userId })
    : Promise.resolve(notConfigured()),
  listParticipationCounts: () => client
    ? client.from("listing_participant_counts").select("listing_id,participant_count")
    : Promise.resolve(notConfigured()),
  listMyParticipations: () => client
    ? client.from("listing_participants").select("listing_id,status")
    : Promise.resolve(notConfigured()),
  requestParticipation: (listingId, applicantName) => client
    ? client.rpc("request_listing_participation", { target_listing_id: listingId, requested_applicant_name: applicantName })
    : Promise.resolve(notConfigured()),
  listListingRequests: (listingId) => client
    ? client.from("listing_participants").select("listing_id,user_id,applicant_name,status,created_at").eq("listing_id", listingId).order("created_at", { ascending: true })
    : Promise.resolve(notConfigured()),
  reviewParticipation: (listingId, userId, decision) => client
    ? client.rpc("review_listing_participation", { target_listing_id: listingId, p_target_user_id: userId, decision })
    : Promise.resolve(notConfigured()),
  getParticipationCount: (listingId) => client
    ? client.from("listing_participant_counts").select("participant_count").eq("listing_id", listingId).maybeSingle()
    : Promise.resolve(notConfigured()),
  subscribeToParticipationChanges: async (filter, onChange, onStatus) => {
    if (!client) return null;
    const { data } = await client.auth.getSession();
    if (data.session?.access_token) await client.realtime.setAuth(data.session.access_token);
    return client.channel(`listing-participants-${filter.replace(/[^a-z0-9-]/gi, "-")}-${Date.now()}`)
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "listing_participants", filter }, (payload) => onChange("INSERT", payload))
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "listing_participants", filter }, (payload) => onChange("UPDATE", payload))
      .subscribe((status, error) => onStatus?.(status, error));
  },
  unsubscribeParticipationChanges: (channel) => client && channel
    ? client.removeChannel(channel)
    : Promise.resolve(),
  cancelParticipation: (listingId) => client
    ? client.rpc("cancel_listing_participation", { target_listing_id: listingId })
    : Promise.resolve(notConfigured()),
  listMessages: (listingId) => client
    ? client.from("listing_messages").select("id,listing_id,sender_id,body,created_at").eq("listing_id", listingId).order("created_at", { ascending: true })
    : Promise.resolve(notConfigured()),
  sendMessage: (listingId, body) => client
    ? client.from("listing_messages").insert({ listing_id: listingId, body }).select().single()
    : Promise.resolve(notConfigured()),
  listMatchMessages: (matchId) => client
    ? client.from("match_messages").select("id,match_id,sender_id,receiver_id,body,created_at").eq("match_id", matchId).order("created_at", { ascending: true })
    : Promise.resolve(notConfigured()),
  sendMatchMessage: async (matchId, receiverId, body) => {
    if (!client) return notConfigured();
    const { data } = await client.auth.getUser();
    return client.from("match_messages").insert({ match_id: matchId, sender_id: data.user?.id, receiver_id: receiverId, body }).select().single();
  },
  getMeetingRecord: (listingId) => client
    ? client.from("meeting_records").select("listing_id,met_safely,meet_again,private_note,updated_at").eq("listing_id", listingId).maybeSingle()
    : Promise.resolve(notConfigured()),
  saveMeetingRecord: (listingId, record) => client
    ? client.from("meeting_records").upsert({ listing_id: listingId, ...record }, { onConflict: "listing_id,user_id" }).select().single()
    : Promise.resolve(notConfigured()),
  countMetPeople: () => client
    ? client.from("meeting_records").select("listing_id", { count: "exact", head: true }).eq("met_safely", true)
    : Promise.resolve(notConfigured()),
  countMeetAgain: () => client
    ? client.from("meeting_records").select("listing_id", { count: "exact", head: true }).eq("meet_again", true)
    : Promise.resolve(notConfigured()),
  getProfile: (userId) => client
    ? client.from("profiles").select("user_id,nickname,age,gender,area,bio,tags,photo_urls,personality_type,personality_title,personality_description,personality_tags,quiet_score,talk_score,comfort_score").eq("user_id", userId).maybeSingle()
    : Promise.resolve(notConfigured()),
  saveProfile: (profile) => client
    ? client.from("profiles").upsert(profile, { onConflict: "user_id" }).select().single()
    : Promise.resolve(notConfigured()),
  savePersonality: (profile) => {
    if (!client) return Promise.resolve(notConfigured());
    const { user_id, ...values } = profile;
    return client.from("profiles").update(values).eq("user_id", user_id);
  },
  uploadProfilePhoto: async (userId, file) => {
    if (!client) return notConfigured();
    const extension = file.name.split(".").pop()?.toLowerCase().replace(/[^a-z0-9]/g, "") || "jpg";
    const path = `${userId}/${crypto.randomUUID()}.${extension}`;
    const result = await client.storage.from("profile-photos").upload(path, file, { upsert: false, contentType: file.type });
    if (result.error) return result;
    return { data: { url: client.storage.from("profile-photos").getPublicUrl(path).data.publicUrl }, error: null };
  },
  listNotifications: () => client
    ? client.from("notifications").select("id,listing_id,type,message,read_at,created_at").order("created_at", { ascending: false }).limit(100)
    : Promise.resolve(notConfigured()),
  markNotificationRead: (id) => client
    ? client.from("notifications").update({ read_at: new Date().toISOString() }).eq("id", id)
    : Promise.resolve(notConfigured()),
  markAllNotificationsRead: () => client
    ? client.from("notifications").update({ read_at: new Date().toISOString() }).is("read_at", null)
    : Promise.resolve(notConfigured()),
  syncListingEndNotifications: () => client
    ? client.rpc("sync_listing_end_notifications")
    : Promise.resolve(notConfigured()),
  subscribeToNotifications: async (userId, onInsert, onStatus) => {
    if (!client) return null;
    const { data } = await client.auth.getSession();
    if (data.session?.access_token) await client.realtime.setAuth(data.session.access_token);
    return client.channel(`notifications-${userId}-${Date.now()}`)
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "notifications", filter: `recipient_id=eq.${userId}` }, (payload) => onInsert(payload.new))
      .subscribe((status, error) => onStatus?.(status, error));
  },
  unsubscribeNotifications: (channel) => client && channel
    ? client.removeChannel(channel)
    : Promise.resolve(),
  subscribeToMessages: async (listingId, onInsert, onStatus) => {
    if (!client) return null;
    const { data } = await client.auth.getSession();
    if (data.session?.access_token) await client.realtime.setAuth(data.session.access_token);
    return client.channel(`listing-messages-${listingId}-${Date.now()}`)
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "listing_messages", filter: `listing_id=eq.${listingId}` }, (payload) => onInsert(payload.new))
      .subscribe((status, error) => onStatus?.(status, error));
  },
  subscribeToMatchMessages: async (matchId, onInsert, onStatus) => {
    if (!client) return null;
    const { data } = await client.auth.getSession();
    if (data.session?.access_token) await client.realtime.setAuth(data.session.access_token);
    const channel = client
      .channel(`tomoni-match-chat-${matchId}`)
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "match_messages", filter: `match_id=eq.${matchId}` }, (payload) => onInsert(payload.new))
      .subscribe((status) => onStatus?.(status));
    return channel;
  },
  unsubscribeMatchMessages: (channel) => client && channel
    ? client.removeChannel(channel)
    : Promise.resolve(),
  unsubscribeMessages: (channel) => client && channel
    ? client.removeChannel(channel)
    : Promise.resolve(),
};

if (client) {
  client.auth.onAuthStateChange((event, session) => {
    window.dispatchEvent(new CustomEvent("tomoni:auth-state", { detail: { event, session } }));
  });
}

window.dispatchEvent(new CustomEvent("tomoni:auth-ready"));
