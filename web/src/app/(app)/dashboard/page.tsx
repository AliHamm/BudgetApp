import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export default async function DashboardPage() {
  const session = await getServerSession(authOptions);
  const userId = session?.user?.id as string;

  const [txCount, budgetCount, goalsCount] = await Promise.all([
    prisma.transaction.count({ where: { userId } }),
    prisma.budget.count({ where: { userId } }),
    prisma.goal.count({ where: { userId } }),
  ]);

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Dashboard</h1>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="border rounded p-4">
          <div className="text-sm text-gray-500">Transactions</div>
          <div className="text-2xl font-medium">{txCount}</div>
        </div>
        <div className="border rounded p-4">
          <div className="text-sm text-gray-500">Budgets</div>
          <div className="text-2xl font-medium">{budgetCount}</div>
        </div>
        <div className="border rounded p-4">
          <div className="text-sm text-gray-500">Goals</div>
          <div className="text-2xl font-medium">{goalsCount}</div>
        </div>
      </div>
    </div>
  );
}

