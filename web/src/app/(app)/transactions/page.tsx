import Link from "next/link";
import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export default async function TransactionsPage() {
  const session = await getServerSession(authOptions);
  const userId = session?.user?.id as string;
  const transactions = await prisma.transaction.findMany({
    where: { userId },
    orderBy: { date: "desc" },
    take: 20,
    include: { category: true },
  });
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Transactions</h1>
        <Link href="/transactions/new" className="bg-black text-white rounded px-3 py-2 text-sm">
          + Add Transaction
        </Link>
      </div>
      <ul className="divide-y">
        {transactions.map((t) => (
          <li key={t.id} className="py-3 flex items-center justify-between">
            <div>
              <div className="font-medium">{t.description ?? "(No description)"}</div>
              <div className="text-sm text-gray-500">
                {t.type} · {t.category?.name ?? "Uncategorized"}
              </div>
            </div>
            <div className="font-mono">{(t.amountCents / 100).toFixed(2)}</div>
          </li>
        ))}
      </ul>
    </div>
  );
}

