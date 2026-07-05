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
};

window.dispatchEvent(new CustomEvent("tomoni:auth-ready"));
