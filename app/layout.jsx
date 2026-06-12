import "./globals.css";
import { Space_Grotesk, Inter } from "next/font/google";
import { SelektorProvider } from "../lib/store";
import TopBar from "../components/TopBar";

const spaceGrotesk = Space_Grotesk({ subsets: ["latin"], weight: ["400","500","600","700"], variable: "--font-space-grotesk", display: "swap" });
const inter = Inter({ subsets: ["latin"], weight: ["400","500","600"], variable: "--font-inter", display: "swap" });

export const metadata = {
  title: "Selektor — Selección de personal",
  description: "Aplicación ligera de selección de personal",
};

export default function RootLayout({ children }) {
  return (
    <html lang="es" className={`${spaceGrotesk.variable} ${inter.variable}`}>
      <body className="sk-body min-h-screen bg-[#F6F7F9] text-[#14181F]">
        <SelektorProvider>
          <TopBar />
          {children}
        </SelektorProvider>
      </body>
    </html>
  );
}
