"use client";

import { signOut } from "next-auth/react";
import { useRouter } from "next/navigation";

export default function SignOutButton() {
  const router = useRouter();

  const handleSignOut = async () => {
    const data = (await signOut({ redirect: false, callbackUrl: "/" })) as
      | undefined
      | { url?: string };
    router.push(data?.url ?? "/");
  };

  return (
    <button
      onClick={handleSignOut}
      className="text-sm border rounded px-3 py-1 hover:bg-gray-50"
      aria-label="Sign out"
    >
      Log out
    </button>
  );
}

