import { defineStore } from 'pinia';
import { ref } from 'vue';
import { saveSession, getSession } from '../services/sessionService';
import { supabase } from '../supabase/client';

export const useAuthStore = defineStore('auth', () => {
  const user = ref();
  const loading = ref(true);

  async function initialize() {
    const storedSession = getSession();
    if (storedSession) {
      user.value = storedSession.user;
      loading.value = false;
    } else {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      user.value = session?.user ?? null;
      saveSession(session);
    }
    loading.value = false;

    supabase.auth.onAuthStateChange((_event, session) => {
      user.value = session?.user ?? null;
      saveSession(session);
    });
  }

  async function signIn(email: string, password: string) {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) {
      saveSession(null);
      throw error;
    }
  }

  async function signUp(email: string, password: string) {
    const { error } = await supabase.auth.signUp({ email, password });
    if (error) {
      saveSession(null);
      throw error;
    }
  }

  async function signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) {
      saveSession(null);
      throw error;
    }
    saveSession(null);
  }

  return {
    user,
    loading,
    initialize,
    signIn,
    signUp,
    signOut,
  };
});
