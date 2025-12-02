import { Building2, Plus, ArrowLeft } from "lucide-react";
import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import Header from "@/components/Header";
import { toast } from "sonner";
import { api, HealthCenter } from "@/lib/api";

const AddCenter = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  
  const [formData, setFormData] = useState<Omit<HealthCenter, 'id'>>({
    name: "",
    code: "",
    city: "",
    address: "",
  });

  const createCenterMutation = useMutation({
    mutationFn: api.createCenter,
    onSuccess: () => {
      toast.success("Centre de santé ajouté avec succès");
      queryClient.invalidateQueries({ queryKey: ["centers"] });
      navigate("/dashboard");
    },
    onError: (error: Error) => {
      toast.error(`Erreur lors de l'ajout du centre: ${error.message}`);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    createCenterMutation.mutate(formData);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-2xl mx-auto p-6">
        <Button
          variant="ghost"
          className="mb-6 px-0"
          onClick={() => navigate(-1)}
        >
          <ArrowLeft className="mr-2 h-4 w-4" />
          Retour
        </Button>

        <h1 className="text-2xl font-bold mb-8">
          <Building2 className="inline-block mr-2 h-6 w-6" />
          Ajouter un centre de santé
        </h1>

        <Card className="p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="name">Nom du centre *</Label>
              <Input
                id="name"
                name="name"
                placeholder="Ex: Centre de Santé de Grand-Yoff"
                value={formData.name}
                onChange={handleChange}
                required
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="code">Code du centre *</Label>
                <Input
                  id="code"
                  name="code"
                  placeholder="Ex: CSG-YF"
                  value={formData.code}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="city">Ville *</Label>
                <Input
                  id="city"
                  name="city"
                  placeholder="Ex: Dakar"
                  value={formData.city}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="address">Adresse complète</Label>
              <Input
                id="address"
                name="address"
                placeholder="Adresse du centre"
                value={formData.address}
                onChange={handleChange}
              />
            </div>

            <div className="pt-4">
              <Button 
                type="submit" 
                className="w-full"
                disabled={createCenterMutation.isPending}
              >
                <Plus className="mr-2 h-4 w-4" />
                {createCenterMutation.isPending ? "Enregistrement..." : "Ajouter le centre"}
              </Button>
            </div>
          </form>
        </Card>
      </main>
    </div>
  );
};

export default AddCenter;