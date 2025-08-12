import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import NewTransactionForm from "@/components/NewTransactionForm";

export default async function NewTransactionPage() {
  const session = await getServerSession(authOptions);
  const userId = session?.user?.id as string;
  const categories = await prisma.category.findMany({
    where: { OR: [{ userId }, { userId: null }] },
    orderBy: { name: "asc" },
  });
  return (
    <div className="max-w-lg">
      <h1 className="text-2xl font-semibold mb-4">Add Transaction</h1>
      <NewTransactionForm categories={categories} />
    </div>
  );
}

