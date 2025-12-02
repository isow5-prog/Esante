import { QrCode } from "lucide-react";
import { useState, useEffect, useRef } from "react";
import { useMutation } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import Header from "@/components/Header";
import { Html5Qrcode } from "html5-qrcode";
import { toast } from "sonner";
import { api } from "@/lib/api";

const ValidateCard = () => {
  const [showForm, setShowForm] = useState(false);
  const [scannedCode, setScannedCode] = useState<string | null>(null);
  const scannerRef = useRef<Html5Qrcode | null>(null);
  const [formData, setFormData] = useState({
    prenom: "",
    adresse: "",
    telephone: "",
    naissance: "",
    profession: "",
  });

  const stopScanner = async () => {
    if (scannerRef.current) {
      try {
        await scannerRef.current.stop();
        await scannerRef.current.clear();
      } catch (err) {
        console.error("Erreur lors de l'arrêt du scanner:", err);
      }
      scannerRef.current = null;
    }
  };

  const startScanner = async () => {
    if (!scannedCode && !scannerRef.current) {
      try {
        const scanner = new Html5Qrcode("qr-reader-validate");
        scannerRef.current = scanner;

        await scanner.start(
          { facingMode: "environment" },
          {
            fps: 10,
            qrbox: { width: 250, height: 250 },
          },
          (decodedText) => {
            setScannedCode(decodedText);
            toast.success("QR Code scanné avec succès!");
            stopScanner();
          },
          () => {
            // Ignorer les erreurs de scan continu
          }
        );
      } catch (err) {
        console.error("Erreur lors du démarrage du scanner:", err);
      }
    }
  };

  const validationMutation = useMutation({
    mutationFn: api.validateCard,
    onSuccess: async () => {
      toast.success("Carte validée avec succès!");
      setShowForm(false);
      setScannedCode(null);
      setFormData({
        prenom: "",
        adresse: "",
        telephone: "",
        naissance: "",
        profession: "",
      });
      await stopScanner();
      // Réinitialiser le scanner après un court délai
      setTimeout(() => {
        startScanner();
      }, 100);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  useEffect(() => {
    startScanner();

    return () => {
      if (scannerRef.current) {
        scannerRef.current.stop().catch(() => {});
        scannerRef.current.clear().catch(() => {});
      }
    };
  }, [scannedCode]);

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-2xl mx-auto p-6">
        <Card className="p-8 mb-6">
          <div className="flex items-center gap-2 mb-6">
            <QrCode className="w-6 h-6 text-muted-foreground" />
            <h2 className="text-xl font-semibold">Scanner un QR Code</h2>
          </div>
          <p className="text-sm text-muted-foreground mb-6">
            Scanner le QR code du carnet de la mère
          </p>

          <div className="w-full h-64 bg-muted rounded-lg flex items-center justify-center mb-6 border-2 border-dashed border-border relative overflow-hidden">
            <div id="qr-reader-validate" className="absolute inset-0 w-full h-full"></div>
            {!scannedCode && (
              <div className="absolute inset-0 flex items-center justify-center pointer-events-none z-10 bg-muted/50">
                <div className="text-center">
                  <QrCode className="w-16 h-16 text-muted-foreground mx-auto mb-2" />
                  <p className="text-sm text-muted-foreground">Zone de scan</p>
                </div>
              </div>
            )}
            {scannedCode && (
              <div className="absolute inset-0 flex items-center justify-center pointer-events-none z-10 bg-background/80">
                <div className="text-center">
                  <QrCode className="w-16 h-16 text-primary mx-auto mb-2" />
                  <p className="text-sm font-medium">QR Code scanné: {scannedCode}</p>
                </div>
              </div>
            )}
          </div>

          {scannedCode && !showForm && (
            <>
              <div className="text-center mb-6">
                <p className="text-lg font-medium mb-4">Voulez vous valider la carte ?</p>
              </div>

              <div className="flex gap-4">
                <Button 
                  variant="destructive" 
                  className="flex-1"
                  size="lg"
                  onClick={async () => {
                    setScannedCode(null);
                    setShowForm(false);
                    await stopScanner();
                    // Réinitialiser le scanner après un court délai
                    setTimeout(() => {
                      startScanner();
                    }, 100);
                  }}
                >
                  Non
                </Button>
                <Button 
                  className="flex-1"
                  size="lg"
                  onClick={() => setShowForm(true)}
                >
                  Oui je valide
                </Button>
              </div>
            </>
          )}
        </Card>

        {showForm && (
          <Card className="p-8">
            <form 
              className="space-y-4"
              onSubmit={(e) => {
                e.preventDefault();
                if (!scannedCode) {
                  toast.error("Veuillez scanner un QR code avant de valider.");
                  return;
                }
                validationMutation.mutate({
                  code: scannedCode,
                  full_name: formData.prenom,
                  address: formData.adresse,
                  phone: formData.telephone,
                  birth_date: formData.naissance,
                  profession: formData.profession,
                });
              }}
            >
              <div className="space-y-2">
                <Label htmlFor="prenom">Prénom et nom</Label>
                <Input 
                  id="prenom" 
                  placeholder="Prénom et nom"
                  value={formData.prenom}
                  onChange={(e) => setFormData({ ...formData, prenom: e.target.value })}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="adresse">Adresse</Label>
                <Input 
                  id="adresse" 
                  placeholder="Adresse"
                  value={formData.adresse}
                  onChange={(e) => setFormData({ ...formData, adresse: e.target.value })}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="telephone">Téléphone</Label>
                <Input 
                  id="telephone" 
                  placeholder="Telephone" 
                  type="tel"
                  value={formData.telephone}
                  onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="naissance">Date de naissance</Label>
                <Input 
                  id="naissance" 
                  placeholder="Date de naissance" 
                  type="date"
                  value={formData.naissance}
                  onChange={(e) => setFormData({ ...formData, naissance: e.target.value })}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="profession">Profession</Label>
                <Input 
                  id="profession" 
                  placeholder="Profession"
                  value={formData.profession}
                  onChange={(e) => setFormData({ ...formData, profession: e.target.value })}
                  required
                />
              </div>

              <Button type="submit" className="w-full" size="lg" disabled={validationMutation.isPending}>
                {validationMutation.isPending ? "Validation..." : "Valider la carte"}
              </Button>
            </form>
          </Card>
        )}
      </main>
    </div>
  );
};

export default ValidateCard;
