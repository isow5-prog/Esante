import { QrCode } from "lucide-react";
import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";  // Ajout de useQuery
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import Header from "@/components/Header";
import QRScanner from "@/components/QRScanner";
import { toast } from "sonner";
import { api } from "@/lib/api";

const AddRecord = () => {
  const [scannedCode, setScannedCode] = useState<string | null>(null);
  const { data: centers = [] } = useQuery({  // Ajout de la requête
    queryKey: ["centers"],
    queryFn: api.getCenters,
  });
  const [formData, setFormData] = useState({
    prenom: "",
    adresse: "",
    telephone: "",
    naissance: "",
    profession: "",
    pereCarnet: "",
    identification: "",
    naissanceMere: "",
    allocation: "",
  });
  const addRecordMutation = useMutation({
    mutationFn: api.addRecord,
    onSuccess: () => {
      toast.success("Carnet ajouté avec succès!");
      setFormData({
        prenom: "",
        adresse: "",
        telephone: "",
        naissance: "",
        profession: "",
        pereCarnet: "",
        identification: "",
        naissanceMere: "",
        allocation: "",
      });
      setScannedCode(null);
    },
    onError: (error: Error) => toast.error(error.message),
  });
  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-2xl mx-auto p-6">
        <h1 className="text-2xl font-bold text-center mb-8">Ajouter un carnet</h1>

        <Card className="p-8 mb-6">
          <div className="flex items-center gap-2 mb-6">
            <QrCode className="w-6 h-6 text-muted-foreground" />
            <h2 className="text-xl font-semibold">Scanner pour ajouter un carnet</h2>
          </div>
          <p className="text-sm text-muted-foreground mb-6">
            Scanner le QR code du carnet de la mère
          </p>

          {!scannedCode ? (
            <QRScanner
              onScanSuccess={(decodedText) => {
                setScannedCode(decodedText);
                toast.success("QR Code scanné avec succès!");
              }}
              onScanError={(error) => {
                console.error("Erreur de scan:", error);
              }}
            />
          ) : (
            <div className="mb-6 p-4 bg-muted rounded-lg">
              <p className="text-sm font-medium mb-2">Code scanné :</p>
              <p className="text-sm text-muted-foreground font-mono">{scannedCode}</p>
              <Button
                variant="outline"
                size="sm"
                className="mt-2"
                onClick={() => {
                  setScannedCode(null);
                }}
              >
                Scanner à nouveau
              </Button>
            </div>
          )}
        </Card>

        <Card className="p-8">
          <h2 className="text-xl font-semibold mb-6">Identification</h2>
          
          <form 
            className="space-y-4"
            onSubmit={(e) => {
              e.preventDefault();
              if (!scannedCode) {
                toast.error("Veuillez scanner une carte valide.");
                return;
              }
              addRecordMutation.mutate({
                code: scannedCode,
                address: formData.adresse,
                phone: formData.telephone,
                birth_date: formData.naissance,
                profession: formData.profession,
                father_name: formData.prenom,
                pere_carnet_center: formData.pereCarnet,
                identification_code: formData.identification,
                mother_center_of_birth: formData.naissanceMere,
                allocation_info: formData.allocation,
              });
            }}
          >
            <div className="space-y-2">
              <Label htmlFor="prenom">Prénom et nom du père</Label>
              <Input 
                id="prenom" 
                placeholder="Prénom et nom du père"
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
                placeholder="Téléphone" 
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

            <div className="space-y-2">
              <Label htmlFor="pere-carnet">Nom du centre père-carnet csd</Label>
              <Input 
                id="pere-carnet" 
                placeholder="Nom du centre père carnet csd"
                value={formData.pereCarnet}
                onChange={(e) => setFormData({ ...formData, pereCarnet: e.target.value })}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="identification">Le code de l'identification de la maisseur</Label>
              <Input 
                id="identification" 
                placeholder="Le code de l'identification de la maisseur"
                value={formData.identification}
                onChange={(e) => setFormData({ ...formData, identification: e.target.value })}
                required
              />
            </div>

           {/* Remplacez le champ naissanceMere existant par ceci : */}
<div className="space-y-2">
  <Label htmlFor="naissanceMere">Centre de naissance (optionnel)</Label>
  <select
    id="naissanceMere"
    value={formData.naissanceMere}
    onChange={(e) => setFormData({ ...formData, naissanceMere: e.target.value })}
    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  >
    <option value="">Sélectionnez un centre de santé (optionnel)</option>
    {centers.map((center) => (
      <option key={center.id} value={center.name}>
        {center.name} - {center.city}
      </option>
    ))}
  </select>
</div>
            <div className="space-y-2">
              <Label htmlFor="allocation">Ils allocation l'femele</Label>
              <Input 
                id="allocation" 
                placeholder="Ils allocation l'femele"
                value={formData.allocation}
                onChange={(e) => setFormData({ ...formData, allocation: e.target.value })}
                required
              />
            </div>

            <Button
              type="submit"
              className="w-full"
              size="lg"
              disabled={!scannedCode || addRecordMutation.isPending}
            >
              {addRecordMutation.isPending ? "Enregistrement..." : "Ajouter le carnet"}
            </Button>
          </form>
        </Card>
      </main>
    </div>
  );
};

export default AddRecord;
