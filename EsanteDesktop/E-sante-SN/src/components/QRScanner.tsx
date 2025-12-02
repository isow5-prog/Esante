import { useEffect, useRef, useState } from "react";
import { Html5Qrcode } from "html5-qrcode";
import { Button } from "@/components/ui/button";
import { QrCode } from "lucide-react";

interface QRScannerProps {
  onScanSuccess: (decodedText: string) => void;
  onScanError?: (error: string) => void;
  className?: string;
}

const QRScanner = ({ onScanSuccess, onScanError, className = "" }: QRScannerProps) => {
  const [isScanning, setIsScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scannerRef = useRef<Html5Qrcode | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const startScanning = async () => {
    try {
      setError(null);
      const scanner = new Html5Qrcode("qr-reader");
      scannerRef.current = scanner;

      await scanner.start(
        { facingMode: "environment" },
        {
          fps: 10,
          qrbox: { width: 250, height: 250 },
        },
        (decodedText) => {
          onScanSuccess(decodedText);
          stopScanning();
        },
        (errorMessage) => {
          // Ignorer les erreurs de scan continu
          if (onScanError) {
            onScanError(errorMessage);
          }
        }
      );

      setIsScanning(true);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "Erreur lors du démarrage du scanner";
      setError(message);
      setIsScanning(false);
    }
  };

  const stopScanning = async () => {
    if (scannerRef.current) {
      try {
        await scannerRef.current.stop();
        await scannerRef.current.clear();
      } catch (err) {
        console.error("Erreur lors de l'arrêt du scanner:", err);
      }
      scannerRef.current = null;
      setIsScanning(false);
    }
  };

  useEffect(() => {
    return () => {
      if (scannerRef.current) {
        scannerRef.current.stop().catch(() => {});
        scannerRef.current.clear().catch(() => {});
      }
    };
  }, []);

  return (
    <div className={className}>
      <div
        ref={containerRef}
        id="qr-reader"
        className="w-full h-64 bg-muted rounded-lg mb-4 border-2 border-dashed border-border overflow-hidden"
      />
      
      {error && (
        <div className="text-sm text-destructive mb-4 text-center">{error}</div>
      )}

      {!isScanning ? (
        <Button onClick={startScanning} className="w-full" size="lg">
          <QrCode className="mr-2 w-4 h-4" />
          Démarrer le scan
        </Button>
      ) : (
        <Button onClick={stopScanning} variant="destructive" className="w-full" size="lg">
          Arrêter le scan
        </Button>
      )}
    </div>
  );
};

export default QRScanner;

