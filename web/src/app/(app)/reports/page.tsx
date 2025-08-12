"use client";

import { useEffect, useState } from "react";
import { Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

type ReportData = { labels: string[]; expenses: number[]; income: number[] };

export default function ReportsPage() {
  const [data, setData] = useState<ReportData>({ labels: [], expenses: [], income: [] });

  useEffect(() => {
    fetch("/api/reports/summary")
      .then((r) => r.json())
      .then((json) => setData(json))
      .catch(() => setData({ labels: [], expenses: [], income: [] }));
  }, []);

  const chartData = {
    labels: data.labels,
    datasets: [
      {
        label: "Expenses",
        data: data.expenses,
        backgroundColor: "rgba(239, 68, 68, 0.6)",
      },
      {
        label: "Income",
        data: data.income,
        backgroundColor: "rgba(16, 185, 129, 0.6)",
      },
    ],
  };

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Reports</h1>
      <div className="bg-white border rounded p-4">
        <Bar data={chartData} />
      </div>
    </div>
  );
}

