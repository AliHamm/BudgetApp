import { NextResponse } from "next/server";
import { z } from "zod";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

const schema = z.object({
  amount: z.string().refine((v) => !isNaN(Number(v)) && Number(v) >= 0, "Invalid amount"),
  type: z.enum(["INCOME", "EXPENSE", "TRANSFER"]),
  categoryId: z.string().optional().nullable(),
  description: z.string().optional().nullable(),
  date: z.string().refine((v) => !isNaN(Date.parse(v)), "Invalid date"),
});

export async function POST(req: Request) {
  const session = await getServerSession(authOptions);
  if (!session?.user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  try {
    const json = await req.json();
    const parsed = schema.safeParse(json);
    if (!parsed.success) return NextResponse.json({ error: "Invalid payload" }, { status: 400 });
    const { amount, type, categoryId, description, date } = parsed.data;
    const amountCents = Math.round(Number(amount) * 100);
    await prisma.transaction.create({
      data: {
        userId: session.user.id,
        amountCents,
        type,
        categoryId: categoryId || undefined,
        description: description || undefined,
        date: new Date(date),
      },
    });
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}

