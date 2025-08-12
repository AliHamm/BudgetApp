import Link from "next/link";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { redirect } from "next/navigation";
import SignOutButton from "@/components/SignOutButton";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const session = await getServerSession(authOptions);
  if (!session?.user) {
    redirect("/login");
  }
  return (
    <div className="min-h-screen grid grid-rows-[auto_1fr]">
      <header className="border-c p-10 grid grid-cols-3 items-center">
        <nav className="flex items-center gap-8 text-sm justify-self-center col-start-2">
          <Link href="/dashboard">Dashboard</Link>
          <Link href="/transactions">Transactions</Link>
          <Link href="/budgets">Budgets</Link>
          <Link href="/reports">Reports</Link>
          <Link href="/goals">Goals</Link>
          <Link href="/settings">Settings</Link>
        </nav>
        <div className="justify-self-end">
          <SignOutButton />
        </div>
      </header>
      <main className="p-4">{children}</main>
    </div>
  );
}

