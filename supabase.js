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
    ? client.from("listing_participants").select("listing_id")
    : Promise.resolve(notConfigured()),
  joinListing: (listingId) => client
    ? client.rpc("join_listing", { target_listing_id: listingId })
    : Promise.resolve(notConfigured()),
  cancelParticipation: (listingId) => client
    ? client.rpc("cancel_listing_participation", { target_listing_id: listingId })
    : Promise.resolve(notConfigured()),
};

window.dispatchEvent(new CustomEvent("tomoni:auth-ready"));
