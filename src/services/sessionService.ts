import { Session } from "@supabase/supabase-js";

export function saveSession(session: Session | null) {
  if (session) {
    localStorage.setItem('userSession', JSON.stringify(session));
  } else {
    localStorage.removeItem('userSession');
  }
}

export function getSession() {
  const session = localStorage.getItem('userSession');
  return session ? JSON.parse(session) : null;
}
