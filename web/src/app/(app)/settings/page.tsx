import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export default async function SettingsPage() {
  const session = await getServerSession(authOptions);
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Settings</h1>
      <div className="border rounded p-4">
        <div className="text-sm text-gray-600">Logged in as</div>
        <div className="font-medium">{session?.user?.email}</div>
      </div>
    </div>
  );
}

