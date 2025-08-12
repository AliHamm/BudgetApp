import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { subMonths, startOfMonth, format } from "date-fns";

export async function GET() {
  const session = await getServerSession(authOptions);
  if (!session?.user) return NextResponse.json({ labels: [], expenses: [], income: [] });
  const userId = session.user.id;

  const now = new Date();
  const months = Array.from({ length: 6 }).map((_, i) => subMonths(now, 5 - i));
  const labels = months.map((m) => format(m, "MMM yyyy"));

  const expenses: number[] = [];
  const income: number[] = [];

  for (const month of months) {
    const start = startOfMonth(month);
    const end = subMonths(start, -1); // next month
    const [exp, inc] = await Promise.all([
      prisma.transaction.aggregate({
        where: { userId, type: "EXPENSE", date: { gte: start, lt: end } },
        _sum: { amountCents: true },
      }),
      prisma.transaction.aggregate({
        where: { userId, type: "INCOME", date: { gte: start, lt: end } },
        _sum: { amountCents: true },
      }),
    ]);
    expenses.push((exp._sum.amountCents ?? 0) / 100);
    income.push((inc._sum.amountCents ?? 0) / 100);
  }

  return NextResponse.json({ labels, expenses, income });
}

