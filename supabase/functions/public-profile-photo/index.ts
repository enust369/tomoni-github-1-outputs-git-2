import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL");
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error("Supabase Edge Function environment is not configured.");
}

const admin = createClient(supabaseUrl, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

Deno.serve(async (request) => {
  if (request.method !== "GET") {
    return new Response("Method not allowed", { status: 405 });
  }

  const requestUrl = new URL(request.url);
  const profileKey = requestUrl.searchParams.get("profile_key") ?? "";
  const photoIndex = Number(requestUrl.searchParams.get("index"));
  if (!/^[a-f0-9]{32}$/.test(profileKey) || !Number.isInteger(photoIndex) || photoIndex < 0 || photoIndex > 2) {
    return new Response("Not found", { status: 404 });
  }

  const { data: photoUrl, error: photoError } = await admin.rpc(
    "get_public_profile_photo_path",
    {
      target_profile_key: profileKey,
      target_photo_index: photoIndex,
    },
  );
  if (photoError || !photoUrl) {
    return new Response("Not found", { status: 404 });
  }

  let objectUrl: URL;
  try {
    objectUrl = new URL(photoUrl);
  } catch {
    return new Response("Not found", { status: 404 });
  }
  const storagePrefix = "/storage/v1/object/public/profile-photos/";
  const prefixIndex = objectUrl.pathname.indexOf(storagePrefix);
  const objectPath = prefixIndex >= 0
    ? objectUrl.pathname.slice(prefixIndex + storagePrefix.length).split("/").map(decodeURIComponent).join("/")
    : "";

  if (objectUrl.origin !== new URL(supabaseUrl).origin || !objectPath) {
    return new Response("Not found", { status: 404 });
  }

  const { data: photo, error: downloadError } = await admin.storage
    .from("profile-photos")
    .download(objectPath);
  if (downloadError || !photo) {
    return new Response("Not found", { status: 404 });
  }

  return new Response(photo, {
    headers: {
      "Content-Type": photo.type || "image/jpeg",
      "Cache-Control": "public, max-age=3600",
    },
  });
});
