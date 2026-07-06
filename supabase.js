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
  resetPassword: (email) => client
    ? client.auth.resetPasswordForEmail(email, { redirectTo: window.location.href.split("#")[0] })
    : Promise.resolve(notConfigured()),
  listListings: () => client
    ? client.from("listings").select("*").order("created_at", { ascending: false })
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
    ? client.rpc("review_listing_participation", { target_listing_id: listingId, target_user_id: userId, decision })
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
  getMeetingRecord: (listingId) => client
    ? client.from("meeting_records").select("listing_id,met_safely,meet_again,private_note,updated_at").eq("listing_id", listingId).maybeSingle()
    : Promise.resolve(notConfigured()),
  saveMeetingRecord: (listingId, record) => client
    ? client.from("meeting_records").upsert({ listing_id: listingId, ...record }, { onConflict: "listing_id,user_id" }).select().single()
    : Promise.resolve(notConfigured()),
  countMetPeople: () => client
    ? client.from("meeting_records").select("listing_id", { count: "exact", head: true }).eq("met_safely", true)
    : Promise.resolve(notConfigured()),
  subscribeToMessages: async (listingId, onInsert, onStatus) => {
    if (!client) return null;
    const { data } = await client.auth.getSession();
    if (data.session?.access_token) await client.realtime.setAuth(data.session.access_token);
    return client.channel(`listing-messages-${listingId}-${Date.now()}`)
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "listing_messages", filter: `listing_id=eq.${listingId}` }, (payload) => onInsert(payload.new))
      .subscribe((status, error) => onStatus?.(status, error));
  },
  unsubscribeMessages: (channel) => client && channel
    ? client.removeChannel(channel)
    : Promise.resolve(),
};

window.dispatchEvent(new CustomEvent("tomoni:auth-ready"));
