import Link from "next/link";
import Image from "next/image";

export default function Home() {
  return (
    <div className="min-h-screen grid place-items-center p-8">
      <div className="fixed top-12 right-4 z-50">
        <Link href="/login" className="border rounded px-12 py-6">Login</Link>
      </div>
      <div className="max-w-xl text-center space-y-6">

        <h1 className="text-8xl font-bold">Bud & Save</h1>
        <p className="text-gray-4xl font-semibold">Create a Budget and Save your Money!.</p>
        <div className="text-4xl font-bold flex items-center justify-center gap-4">
          <Link href="/signup" className=" border rounded px-14 py-7">Get Started!</Link>
        </div>
      </div>
    </div>
  );
}
