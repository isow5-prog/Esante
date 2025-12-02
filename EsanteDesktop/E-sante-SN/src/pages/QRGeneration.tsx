import { Download, Plus } from "lucide-react";
import { useState, useRef, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import QRCode from "qrcode";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import Header from "@/components/Header";
import { api, QRCodeCard as QRCodeCardType } from "@/lib/api";
import { toast } from "sonner";

const QRCodeMini = ({ code }: { code: string }) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (canvasRef.current) {
      QRCode.toCanvas(canvasRef.current, code, {
        width: 56,
        margin: 1,
      }).catch(console.error);
    }
  }, [code]);

  return <canvas ref={canvasRef} className="max-w-full max-h-full" />;
};

const QRGeneration = () => {
  const [currentCode, setCurrentCode] = useState("");
  const [newCodeInput, setNewCodeInput] = useState("");
  const [qrCodeDataUrl, setQrCodeDataUrl] = useState<string>("");
  const qrCodeRef = useRef<HTMLCanvasElement>(null);
  const queryClient = useQueryClient();
  const { data: qrCodes } = useQuery({
    queryKey: ["qr-cards"],
    queryFn: api.getQrCards,
  });
  const createMutation = useMutation({
    mutationFn: api.createQrCode,
    onSuccess: (data) => {
      toast.success("QR code généré et sauvegardé");
      setCurrentCode(data.code);
      setNewCodeInput("");
      queryClient.invalidateQueries({ queryKey: ["qr-cards"] });
    },
    onError: (error: Error) => toast.error(error.message),
  });

  useEffect(() => {
    if (!currentCode && qrCodes && qrCodes.length > 0) {
      setCurrentCode(qrCodes[0].code);
    }
  }, [currentCode, qrCodes]);

  useEffect(() => {
    const generateQR = async () => {
      if (!currentCode.trim()) {
        setQrCodeDataUrl("");
        if (qrCodeRef.current) {
          const context = qrCodeRef.current.getContext("2d");
          context?.clearRect(
            0,
            0,
            qrCodeRef.current.width,
            qrCodeRef.current.height,
          );
        }
        return;
      }

      if (qrCodeRef.current) {
        try {
          await QRCode.toCanvas(qrCodeRef.current, currentCode, {
            width: 200,
            margin: 2,
            color: {
              dark: "#000000",
              light: "#FFFFFF",
            },
          });
          const dataUrl = await QRCode.toDataURL(currentCode, {
            width: 200,
            margin: 2,
          });
          setQrCodeDataUrl(dataUrl);
        } catch (err) {
          console.error("Erreur lors de la génération du QR code:", err);
        }
      }
    };
    generateQR();
  }, [currentCode]);

  const handleGenerateNew = () => {
    createMutation.mutate(
      newCodeInput.trim()
        ? { code: newCodeInput.trim() }
        : undefined,
    );
  };

  const handleDownload = () => {
    if (!qrCodeDataUrl) return;
    
    const downloadLink = document.createElement("a");
    downloadLink.download = `qr-code-${currentCode}.png`;
    downloadLink.href = qrCodeDataUrl;
    downloadLink.click();
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-4xl mx-auto p-6">
        <h1 className="text-3xl font-bold text-center mb-8">Génération de QR Code</h1>

        <Card className="p-8 mb-8">
          <div className="flex flex-col items-center">
            <div className="w-64 h-64 bg-card border-4 border-foreground flex items-center justify-center mb-6 p-4">
              <canvas
                ref={qrCodeRef}
                className="max-w-full max-h-full"
              />
            </div>
            
            <div className="text-center mb-6 w-full max-w-xs">
              <p className="text-sm text-muted-foreground mb-2">
                Code : {currentCode || "Aucun code sélectionné"}
              </p>
              
              <div className="space-y-2 mb-4">
                <Label htmlFor="new-code">Générer un nouveau code</Label>
                <div className="flex gap-2">
                  <Input
                    id="new-code"
                    placeholder="Code personnalisé (optionnel)"
                    value={newCodeInput}
                    onChange={(e) => setNewCodeInput(e.target.value)}
                  />
                  <Button onClick={handleGenerateNew} variant="outline">
                    <Plus className="w-4 h-4" />
                  </Button>
                </div>
              </div>
            </div>

            <div className="flex gap-2 w-full max-w-xs">
              <Button
                onClick={handleGenerateNew}
                variant="outline"
                className="flex-1"
                disabled={createMutation.isPending}
              >
                {createMutation.isPending ? "Création..." : "Enregistrer le code"}
              </Button>
              <Button onClick={handleDownload} className="flex-1">
                <Download className="mr-2 w-4 h-4" />
                Télécharger
              </Button>
            </div>
          </div>
        </Card>

        <Card className="p-6">
          <h2 className="text-xl font-bold mb-6">Liste QR Code générés</h2>
          
          <div className="space-y-4">
            {qrCodes?.map((qr: QRCodeCardType) => (
              <div
                key={qr.id}
                className="flex items-center justify-between p-4 border rounded-lg cursor-pointer hover:bg-muted/50 transition-colors"
                onClick={() => setCurrentCode(qr.code)}
              >
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 bg-card border rounded flex items-center justify-center p-1">
                    <QRCodeMini code={qr.code} />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Code : {qr.code}</p>
                    <p className="text-xs text-muted-foreground">
                      {new Date(qr.created_at).toLocaleString("fr-FR")}
                    </p>
                  </div>
                </div>
                <span
                  className={`text-sm font-medium ${
                    qr.status === "validated" ? "text-primary" : "text-destructive"
                  }`}
                >
                  {qr.status === "validated" ? "Validé" : "En attente"}
                </span>
              </div>
            ))}
          </div>
        </Card>
      </main>
    </div>
  );
};

export default QRGeneration;
