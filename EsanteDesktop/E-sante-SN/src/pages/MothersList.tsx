import { 
  Search, Users, Filter, Eye, Phone, MapPin, Calendar, 
  QrCode, CheckCircle2, Clock, Download, Sparkles,
  ChevronLeft, ChevronRight, Baby, Heart
} from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import Header from "@/components/Header";
import StatCard from "@/components/StatCard";

// Données fictives pour le prototype
const mockMothers = [
  {
    id: 1,
    qr_code: "QR-FKAX2Z88",
    full_name: "Fatou Diallo",
    phone: "77 123 45 67",
    address: "Dakar, Médina",
    birth_date: "1995-03-15",
    profession: "Commerçante",
    center: "Centre de Santé Grand-Yoff",
    status: "validated",
    created_at: "2025-11-25",
    pregnancies: 2,
  },
  {
    id: 2,
    qr_code: "QR-OFAEKSH7",
    full_name: "Aminata Sow",
    phone: "78 234 56 78",
    address: "Dakar, Parcelles Assainies",
    birth_date: "1998-07-22",
    profession: "Enseignante",
    center: "Centre de Santé Parcelles",
    status: "validated",
    created_at: "2025-11-24",
    pregnancies: 1,
  },
  {
    id: 3,
    qr_code: "QR-1KA2NDAB",
    full_name: "Mariama Ba",
    phone: "76 345 67 89",
    address: "Thiès, Centre-ville",
    birth_date: "1992-11-08",
    profession: "Sage-femme",
    center: "Centre de Santé Thiès",
    status: "validated",
    created_at: "2025-11-23",
    pregnancies: 3,
  },
  {
    id: 4,
    qr_code: "QR-YTEUGQ0C",
    full_name: "Khady Ndiaye",
    phone: "70 456 78 90",
    address: "Saint-Louis, Sor",
    birth_date: "2000-01-30",
    profession: "Étudiante",
    center: "Centre de Santé Saint-Louis",
    status: "validated",
    created_at: "2025-11-22",
    pregnancies: 1,
  },
  {
    id: 5,
    qr_code: "QR-PENDING1",
    full_name: "-",
    phone: "-",
    address: "-",
    birth_date: "-",
    profession: "-",
    center: "-",
    status: "pending",
    created_at: "2025-11-20",
    pregnancies: 0,
  },
];

const mockCenters = [
  "Tous les centres",
  "Centre de Santé Grand-Yoff",
  "Centre de Santé Parcelles",
  "Centre de Santé Thiès",
  "Centre de Santé Saint-Louis",
];

const MothersList = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [centerFilter, setCenterFilter] = useState("Tous les centres");
  const [selectedMother, setSelectedMother] = useState<typeof mockMothers[0] | null>(null);

  const filteredMothers = mockMothers.filter((mother) => {
    const matchesSearch =
      mother.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      mother.qr_code.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === "all" || mother.status === statusFilter;
    const matchesCenter =
      centerFilter === "Tous les centres" || mother.center === centerFilter;
    return matchesSearch && matchesStatus && matchesCenter;
  });

  const totalMothers = mockMothers.length;
  const activeMothers = mockMothers.filter((m) => m.status === "validated").length;
  const pendingCards = mockMothers.filter((m) => m.status === "pending").length;

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="max-w-7xl mx-auto p-6">
        {/* Page Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8 animate-slide-up">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Sparkles className="w-5 h-5 text-primary" />
              <span className="text-sm font-medium text-primary">Gestion des mères</span>
            </div>
            <h1 className="text-3xl font-bold text-foreground">Liste des Mères</h1>
            <p className="text-muted-foreground mt-1">
              Suivez et gérez toutes les mères inscrites dans le système
            </p>
          </div>
          <Button className="rounded-xl h-11 px-6">
            <Download className="mr-2 w-4 h-4" />
            Exporter en CSV
          </Button>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="animate-slide-up delay-100">
            <StatCard
              icon={Users}
              title="Total Mères"
              value={totalMothers}
              subtitle="Dans le système"
              color="green"
            />
          </div>
          <div className="animate-slide-up delay-200">
            <StatCard
              icon={CheckCircle2}
              title="Cartes Actives"
              value={activeMothers}
              subtitle="Cartes validées"
              color="blue"
            />
          </div>
          <div className="animate-slide-up delay-300">
            <StatCard
              icon={Clock}
              title="En Attente"
              value={pendingCards}
              subtitle="À activer"
              color="orange"
            />
          </div>
          <div className="animate-slide-up delay-400">
            <StatCard
              icon={Baby}
              title="Grossesses"
              value={mockMothers.reduce((acc, m) => acc + m.pregnancies, 0)}
              subtitle="Total suivies"
              color="purple"
            />
          </div>
        </div>

        {/* Search & Filters */}
        <div className="bg-card rounded-2xl border border-border/50 p-6 mb-6 animate-slide-up delay-200">
          <div className="flex flex-col lg:flex-row gap-4">
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                <Input
                  placeholder="Rechercher par nom, téléphone ou code QR..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-12 h-12 rounded-xl bg-muted/50 border-border/50"
                />
              </div>
            </div>
            <div className="flex gap-3">
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[180px] h-12 rounded-xl">
                  <Filter className="w-4 h-4 mr-2 text-muted-foreground" />
                  <SelectValue placeholder="Statut" />
                </SelectTrigger>
                <SelectContent className="rounded-xl">
                  <SelectItem value="all">Tous les statuts</SelectItem>
                  <SelectItem value="validated">Actives</SelectItem>
                  <SelectItem value="pending">En attente</SelectItem>
                </SelectContent>
              </Select>
              <Select value={centerFilter} onValueChange={setCenterFilter}>
                <SelectTrigger className="w-[240px] h-12 rounded-xl">
                  <SelectValue placeholder="Centre de santé" />
                </SelectTrigger>
                <SelectContent className="rounded-xl">
                  {mockCenters.map((center) => (
                    <SelectItem key={center} value={center}>
                      {center}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
        </div>

        {/* Mothers Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
          {filteredMothers.map((mother, index) => (
            <div
              key={mother.id}
              className={`
                bg-card rounded-2xl border border-border/50 p-5 
                hover:border-primary/30 hover:shadow-lg hover:shadow-primary/5 
                transition-all duration-300 cursor-pointer group
                animate-slide-up
              `}
              style={{ animationDelay: `${index * 50}ms` }}
            >
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className={`
                    w-12 h-12 rounded-xl flex items-center justify-center
                    ${mother.status === "validated" 
                      ? "bg-gradient-to-br from-primary/20 to-emerald-500/20" 
                      : "bg-muted"
                    }
                  `}>
                    {mother.status === "validated" ? (
                      <span className="text-lg font-bold text-primary">
                        {mother.full_name.charAt(0)}
                      </span>
                    ) : (
                      <QrCode className="w-5 h-5 text-muted-foreground" />
                    )}
                  </div>
                  <div>
                    <h3 className="font-semibold group-hover:text-primary transition-colors">
                      {mother.status === "validated" ? mother.full_name : "Non assignée"}
                    </h3>
                    <div className="flex items-center gap-1 text-xs text-muted-foreground font-mono">
                      <QrCode className="w-3 h-3" />
                      {mother.qr_code}
                    </div>
                  </div>
                </div>
                <Badge
                  className={`
                    rounded-full px-3 py-1 text-xs font-medium
                    ${mother.status === "validated"
                      ? "bg-emerald-500/10 text-emerald-600 border border-emerald-500/20"
                      : "bg-amber-500/10 text-amber-600 border border-amber-500/20"
                    }
                  `}
                >
                  {mother.status === "validated" ? (
                    <><CheckCircle2 className="w-3 h-3 mr-1" /> Active</>
                  ) : (
                    <><Clock className="w-3 h-3 mr-1" /> En attente</>
                  )}
                </Badge>
              </div>

              {mother.status === "validated" && (
                <>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Phone className="w-4 h-4" />
                      {mother.phone}
                    </div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <MapPin className="w-4 h-4" />
                      {mother.address}
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-4 border-t border-border/50">
                    <div className="flex items-center gap-4">
                      <div className="flex items-center gap-1 text-xs text-muted-foreground">
                        <Baby className="w-4 h-4" />
                        {mother.pregnancies} grossesse(s)
                      </div>
                    </div>
                    <Dialog>
                      <DialogTrigger asChild>
                        <Button
                          variant="ghost"
                          size="sm"
                          className="rounded-lg"
                          onClick={() => setSelectedMother(mother)}
                        >
                          <Eye className="w-4 h-4 mr-1" />
                          Détails
                        </Button>
                      </DialogTrigger>
                      <DialogContent className="max-w-md rounded-2xl">
                        <DialogHeader>
                          <DialogTitle>Détails de la mère</DialogTitle>
                        </DialogHeader>
                        {selectedMother && selectedMother.status === "validated" && (
                          <div className="space-y-4 mt-4">
                            <div className="flex flex-col items-center mb-6">
                              <div className="w-20 h-20 rounded-2xl gradient-primary flex items-center justify-center mb-3 shadow-lg shadow-primary/30">
                                <span className="text-3xl font-bold text-white">
                                  {selectedMother.full_name.charAt(0)}
                                </span>
                              </div>
                              <h3 className="text-xl font-bold">{selectedMother.full_name}</h3>
                              <p className="text-sm text-muted-foreground font-mono flex items-center gap-1">
                                <QrCode className="w-3 h-3" />
                                {selectedMother.qr_code}
                              </p>
                            </div>
                            <div className="grid grid-cols-2 gap-3">
                              <div className="p-4 rounded-xl bg-muted/50">
                                <div className="flex items-center gap-2 text-primary mb-1">
                                  <Phone className="w-4 h-4" />
                                  <span className="text-xs font-medium">Téléphone</span>
                                </div>
                                <p className="font-semibold">{selectedMother.phone}</p>
                              </div>
                              <div className="p-4 rounded-xl bg-muted/50">
                                <div className="flex items-center gap-2 text-primary mb-1">
                                  <Calendar className="w-4 h-4" />
                                  <span className="text-xs font-medium">Naissance</span>
                                </div>
                                <p className="font-semibold">
                                  {new Date(selectedMother.birth_date).toLocaleDateString("fr-FR")}
                                </p>
                              </div>
                              <div className="p-4 rounded-xl bg-muted/50 col-span-2">
                                <div className="flex items-center gap-2 text-primary mb-1">
                                  <MapPin className="w-4 h-4" />
                                  <span className="text-xs font-medium">Adresse</span>
                                </div>
                                <p className="font-semibold">{selectedMother.address}</p>
                              </div>
                              <div className="p-4 rounded-xl bg-muted/50">
                                <div className="flex items-center gap-2 text-primary mb-1">
                                  <Users className="w-4 h-4" />
                                  <span className="text-xs font-medium">Profession</span>
                                </div>
                                <p className="font-semibold">{selectedMother.profession}</p>
                              </div>
                              <div className="p-4 rounded-xl bg-muted/50">
                                <div className="flex items-center gap-2 text-primary mb-1">
                                  <Baby className="w-4 h-4" />
                                  <span className="text-xs font-medium">Grossesses</span>
                                </div>
                                <p className="font-semibold">{selectedMother.pregnancies}</p>
                              </div>
                            </div>
                            <Button className="w-full rounded-xl h-11">
                              <Heart className="w-4 h-4 mr-2" />
                              Voir le carnet de santé
                            </Button>
                          </div>
                        )}
                      </DialogContent>
                    </Dialog>
                  </div>
                </>
              )}

              {mother.status === "pending" && (
                <div className="text-center py-4">
                  <p className="text-sm text-muted-foreground">
                    Carte en attente d'activation
                  </p>
                </div>
              )}
            </div>
          ))}
        </div>

        {filteredMothers.length === 0 && (
          <div className="bg-card rounded-2xl border border-border/50 p-12 text-center">
            <Users className="w-16 h-16 text-muted-foreground/30 mx-auto mb-4" />
            <h3 className="text-lg font-semibold mb-2">Aucune mère trouvée</h3>
            <p className="text-muted-foreground">
              Essayez de modifier vos critères de recherche
            </p>
          </div>
        )}

        {/* Pagination */}
        <div className="flex items-center justify-between mt-6">
          <p className="text-sm text-muted-foreground">
            Affichage de <span className="font-semibold">{filteredMothers.length}</span> sur <span className="font-semibold">{totalMothers}</span> mères
          </p>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" className="rounded-lg" disabled>
              <ChevronLeft className="w-4 h-4 mr-1" />
              Précédent
            </Button>
            <Button variant="outline" size="sm" className="rounded-lg" disabled>
              Suivant
              <ChevronRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default MothersList;
