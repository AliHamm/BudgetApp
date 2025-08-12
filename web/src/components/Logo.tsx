import Link from "next/link";
import Image from "next/image";

type Props = {
  size?: number;
};

export default function Logo({ size = 40 }: Props) {
  return (
    <Link href="/" aria-label="Home" className="inline-flex items-center gap-2">
      <Image src="/logo.png" alt="Logo" width={size} height={size} className="h-auto w-auto" />
    </Link>
  );
}

