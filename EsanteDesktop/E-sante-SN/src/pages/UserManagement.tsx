import { Users, UserPlus, Search, Shield, Stethoscope, Mail, Phone, Building2 } from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import Header from "@/components/Header";

// Données fictives pour le prototype
const mockUsers = [
  {
    id: 1,
    badge_id: "ADMIN-001",
    full_name: "Admin System",
    email: "admin@esante.sn",
    phone: "77 000 00 00",
    role: "MINISTRY",
    center: "Ministère de la Santé",
    is_active: true,
  },
  {
    id: 2,
    badge_id: "AGENT-2LJ7WOFD",
    full_name: "Aissatou Nanky",
    email: "aissatou@gmail.com",
    phone: "77 123 45 67",
    role: "HEALTH_WORKER",
    center: "Centre de Santé Grand-Yoff",
    is_active: true,
  },
  {
    id: 3,
    badge_id: "AGENT-9YWG2RKH",
    full_name: "Mouhamed Sow",
    email: "mouhamed@gmail.com",
    phone: "78 234 56 78",
    role: "HEALTH_WORKER",
    center: "Centre de Santé Parcelles",
    is_active: true,
  },
  {
    id: 4,
    badge_id: "MINIS271210",
    full_name: "Younouss Sow",
    email: "younouss@esante.sn",
    phone: "70 456 78 90",
    role: "MINISTRY",
    center: "Ministère de la Santé",
    is_active: true,
  },
];

const mockCenters = [
  "Centre de Santé Grand-Yoff",
  "Centre de Santé Parcelles",
  "Centre de Santé Thiès",
];

const UserManagement = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [newUser, setNewUser] = useState({
    first_name: "",
    last_name: "",
    email: "",
    phone: "",
    role: "HEALTH_WORKER",
    center: "",
  });

  const filteredUsers = mockUsers.filter((user) =>
    user.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.badge_id.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getInitials = (name: string) => {
    return name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="max-w-7xl mx-auto p-6">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Gestion des Utilisateurs</h1>
            <p className="text-muted-foreground mt-1">
              Gérez les comptes des agents de santé et du ministère
            </p>
          </div>
          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger asChild>
              <Button className="gap-2">
                <UserPlus className="w-4 h-4" />
                Nouvel utilisateur
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-md">
              <DialogHeader>
                <DialogTitle>Créer un nouvel utilisateur</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 mt-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Prénom</Label>
                    <Input
                      placeholder="Prénom"
                      value={newUser.first_name}
                      onChange={(e) => setNewUser({ ...newUser, first_name: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Nom</Label>
                    <Input
                      placeholder="Nom"
                      value={newUser.last_name}
                      onChange={(e) => setNewUser({ ...newUser, last_name: e.target.value })}
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label>Email</Label>
                  <Input
                    type="email"
                    placeholder="email@exemple.com"
                    value={newUser.email}
                    onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Téléphone</Label>
                  <Input
                    placeholder="77 XXX XX XX"
                    value={newUser.phone}
                    onChange={(e) => setNewUser({ ...newUser, phone: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Rôle</Label>
                  <Select
                    value={newUser.role}
                    onValueChange={(value) => setNewUser({ ...newUser, role: value })}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Sélectionner un rôle" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="HEALTH_WORKER">Agent de Santé</SelectItem>
                      <SelectItem value="MINISTRY">Ministère</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                {newUser.role === "HEALTH_WORKER" && (
                  <div className="space-y-2">
                    <Label>Centre de santé</Label>
                    <Select
                      value={newUser.center}
                      onValueChange={(value) => setNewUser({ ...newUser, center: value })}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Sélectionner un centre" />
                      </SelectTrigger>
                      <SelectContent>
                        {mockCenters.map((center) => (
                          <SelectItem key={center} value={center}>
                            {center}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                )}
              </div>
              <DialogFooter className="mt-6">
                <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
                  Annuler
                </Button>
                <Button onClick={() => setIsDialogOpen(false)}>Créer</Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>

        {/* Statistiques */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-primary/10">
                <Users className="w-6 h-6 text-primary" />
              </div>
              <div>
                <p className="text-2xl font-bold">{mockUsers.length}</p>
                <p className="text-sm text-muted-foreground">Total utilisateurs</p>
              </div>
            </div>
          </Card>
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-secondary/10">
                <Shield className="w-6 h-6 text-secondary" />
              </div>
              <div>
                <p className="text-2xl font-bold">{mockUsers.filter(u => u.role === "MINISTRY").length}</p>
                <p className="text-sm text-muted-foreground">Ministère</p>
              </div>
            </div>
          </Card>
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-green-500/10">
                <Stethoscope className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{mockUsers.filter(u => u.role === "HEALTH_WORKER").length}</p>
                <p className="text-sm text-muted-foreground">Agents de santé</p>
              </div>
            </div>
          </Card>
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-emerald-500/10">
                <Users className="w-6 h-6 text-emerald-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{mockUsers.filter(u => u.is_active).length}</p>
                <p className="text-sm text-muted-foreground">Comptes actifs</p>
              </div>
            </div>
          </Card>
        </div>

        {/* Recherche */}
        <Card className="p-6 mb-6">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Rechercher par nom ou badge..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </Card>

        {/* Liste des utilisateurs */}
        <div className="grid gap-4">
          {filteredUsers.map((user) => (
            <Card key={user.id} className="p-6 hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-full flex items-center justify-center text-white font-bold ${
                    user.role === "MINISTRY" ? "bg-secondary" : "bg-primary"
                  }`}>
                    {getInitials(user.full_name)}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold text-foreground">{user.full_name}</h3>
                      <Badge variant="outline" className="border-green-500 text-green-600">
                        Actif
                      </Badge>
                    </div>
                    <p className="text-sm text-muted-foreground font-mono">{user.badge_id}</p>
                  </div>
                </div>

                <div className="hidden md:flex items-center gap-8">
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Mail className="w-4 h-4" />
                    {user.email}
                  </div>
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Phone className="w-4 h-4" />
                    {user.phone}
                  </div>
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Building2 className="w-4 h-4" />
                    {user.center}
                  </div>
                </div>

                <Badge className={user.role === "MINISTRY" ? "bg-secondary" : "bg-primary"}>
                  {user.role === "MINISTRY" ? (
                    <><Shield className="w-3 h-3 mr-1" />Ministère</>
                  ) : (
                    <><Stethoscope className="w-3 h-3 mr-1" />Agent</>
                  )}
                </Badge>
              </div>
            </Card>
          ))}
        </div>

        {filteredUsers.length === 0 && (
          <Card className="p-8">
            <div className="text-center">
              <Users className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
              <p className="text-muted-foreground">Aucun utilisateur trouvé</p>
            </div>
          </Card>
        )}
      </main>
    </div>
  );
};

export default UserManagement;
