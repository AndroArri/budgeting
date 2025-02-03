import { Session } from "@supabase/supabase-js";

export function saveSession(session: Session | null) {
  if (session) {
    const sessionData = {
      session,
      expiry: new Date().getTime() + 24 * 60 * 60 * 1000, // 24 hours from now
    };
    localStorage.setItem('userSession', JSON.stringify(sessionData));
  } else {
    localStorage.removeItem('userSession');
  }
}

export function getSession() {
  const sessionData = localStorage.getItem('userSession');
  if (!sessionData) return null;

  const { session, expiry } = JSON.parse(sessionData);
  if (new Date().getTime() > expiry) {
    localStorage.removeItem('userSession');
    return null;
  }
  return session;
}
