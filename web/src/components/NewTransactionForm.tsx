"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
type TransactionType = "INCOME" | "EXPENSE" | "TRANSFER";
type CategoryOption = { id: string; name: string; type: TransactionType };

type Props = { categories: CategoryOption[] };

export default function NewTransactionForm({ categories }: Props) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({
    amount: "",
    type: "EXPENSE" as TransactionType,
    categoryId: "",
    description: "",
    date: new Date().toISOString().slice(0, 10),
  });

  const onSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    startTransition(async () => {
      const res = await fetch("/api/transactions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        setError(data?.error ?? "Failed to create transaction");
        return;
      }
      router.push("/transactions");
    });
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm mb-1">Amount</label>
          <input
            name="amount"
            value={form.amount}
            onChange={handleChange}
            type="number"
            step="0.01"
            min="0"
            className="w-full border rounded px-3 py-2"
            required
          />
        </div>
        <div>
          <label className="block text-sm mb-1">Type</label>
          <select name="type" value={form.type} onChange={handleChange} className="w-full border rounded px-3 py-2">
            <option value="INCOME">INCOME</option>
            <option value="EXPENSE">EXPENSE</option>
            <option value="TRANSFER">TRANSFER</option>
          </select>
        </div>
      </div>
      <div>
        <label className="block text-sm mb-1">Category</label>
        <select name="categoryId" value={form.categoryId} onChange={handleChange} className="w-full border rounded px-3 py-2">
          <option value="">Uncategorized</option>
          {categories
            .filter((c) => c.type === form.type)
            .map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
        </select>
      </div>
      <div>
        <label className="block text-sm mb-1">Description</label>
        <input name="description" value={form.description} onChange={handleChange} className="w-full border rounded px-3 py-2" />
      </div>
      <div>
        <label className="block text-sm mb-1">Date</label>
        <input name="date" value={form.date} onChange={handleChange} type="date" className="w-full border rounded px-3 py-2" />
      </div>
      {error && <p className="text-sm text-red-600">{error}</p>}
      <button type="submit" disabled={isPending} className="bg-black text-white rounded px-4 py-2 disabled:opacity-50">
        {isPending ? "Saving..." : "Save"}
      </button>
    </form>
  );
}

