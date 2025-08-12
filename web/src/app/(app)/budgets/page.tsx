import Link from "next/link";
import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export default async function BudgetsPage() {
  const session = await getServerSession(authOptions);
  const userId = session?.user?.id as string;
  const budgets = await prisma.budget.findMany({
    where: { userId },
    orderBy: { startDate: "desc" },
    take: 20,
    include: { allocations: { include: { category: true } } },
  });
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Budgets</h1>
        <Link href="/budgets/new" className="bg-white text-white rounded px-3 py-2 text-sm">
          + Add Budget
        </Link>
      </div>
      <ul className="space-y-3">
        {budgets.map((b) => (
          <li key={b.id} className="border rounded p-4">
            <div className="font-medium">{b.name}</div>
            <div className="text-sm text-white-600">
              {new Date(b.startDate).toLocaleDateString()} - {new Date(b.endDate).toLocaleDateString()}
            </div>
            <ul className="mt-2 text-sm text-white-700">
              {b.allocations.map((a) => (
                <li key={a.id}>
                  {a.category?.name ?? "Uncategorized"}: {(a.amountCents / 100).toFixed(2)}
                </li>
              ))}
            </ul>
          </li>
        ))}
      </ul>
    </div>
  );
}

