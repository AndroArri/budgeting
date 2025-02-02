export function saveSession(session: any) {
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
