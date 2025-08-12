import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export default async function GoalsPage() {
  const session = await getServerSession(authOptions);
  const userId = session?.user?.id as string;
  const goals = await prisma.goal.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  return (
    
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Goals</h1>
      <ul className="space-y-3">
        {goals.map((g) => (
          <li key={g.id} className="border rounded p-4">
            <div className="font-medium">{g.name}</div>
            <div className="text-sm text-gray-600">
              {(g.currentAmountCents / 100).toFixed(2)} / {(g.targetAmountCents / 100).toFixed(2)}
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

