import { useState } from "react";
import { 
  ScanLine, Search, User, Phone, MapPin, Calendar,
  Baby, Heart, Syringe, ClipboardCheck, FileText,
  ChevronRight, Plus, QrCode, Sparkles, AlertCircle,
  CheckCircle2, Stethoscope, Pill, CalendarDays
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import Header from "@/components/Header";

// Données fictives pour le prototype
const mockPatientData = {
  id: 1,
  qr_code: "QR-FKAX2Z88",
  full_name: "Fatou Diallo",
  phone: "77 123 45 67",
  address: "Dakar, Médina",
  birth_date: "1995-03-15",
  profession: "Commerçante",
  age: 29,
  blood_group: "O+",
  current_pregnancy: {
    numero: 2,
    semaine: 24,
    date_derniere_regles: "2025-06-01",
    date_accouchement_prevue: "2026-03-08",
  },
  spouse: {
    name: "Mamadou Diop",
    phone: "76 987 65 43",
    blood_group: "A+",
  },
  consultations: [
    { id: 1, date: "2025-09-15", cpn: 1, semaine: 12, poids: 62, tension: "120/80", notes: "RAS" },
    { id: 2, date: "2025-10-20", cpn: 2, semaine: 16, poids: 64, tension: "118/78", notes: "Évolution normale" },
    { id: 3, date: "2025-11-25", cpn: 3, semaine: 24, poids: 66, tension: "122/80", notes: "Bébé en bonne santé" },
  ],
  vaccinations: [
    { id: 1, name: "VAT 1", date: "2025-09-15", done: true },
    { id: 2, name: "VAT 2", date: "2025-10-20", done: true },
    { id: 3, name: "VAT Rappel", date: "2025-12-15", done: false },
  ],
  appointments: [
    { id: 1, date: "2025-12-10", type: "CPN 4", heure: "10:00" },
    { id: 2, date: "2025-12-15", type: "Vaccination", heure: "09:00" },
  ],
  treatments: [
    { id: 1, name: "Fer + Acide folique", dosage: "1 cp/jour", status: "active" },
    { id: 2, name: "Calcium", dosage: "500mg x 2/jour", status: "active" },
  ],
};

const ConsultRecord = () => {
  const [qrCode, setQrCode] = useState("");
  const [isScanning, setIsScanning] = useState(false);
  const [patient, setPatient] = useState<typeof mockPatientData | null>(null);
  const [error, setError] = useState("");

  const handleSearch = () => {
    if (!qrCode.trim()) {
      setError("Veuillez entrer un code QR");
      return;
    }
    
    // Simulation de recherche
    setIsScanning(true);
    setTimeout(() => {
      if (qrCode.toUpperCase().includes("QR-")) {
        setPatient(mockPatientData);
        setError("");
      } else {
        setError("QR code invalide ou non trouvé");
        setPatient(null);
      }
      setIsScanning(false);
    }, 800);
  };

  const handleScan = () => {
    setIsScanning(true);
    // Simulation de scan QR
    setTimeout(() => {
      setQrCode("QR-FKAX2Z88");
      setPatient(mockPatientData);
      setError("");
      setIsScanning(false);
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="max-w-7xl mx-auto p-6">
        {/* Header */}
        <div className="mb-8 animate-slide-up">
          <div className="flex items-center gap-2 mb-2">
            <Sparkles className="w-5 h-5 text-primary" />
            <span className="text-sm font-medium text-primary">Consultation dossier</span>
          </div>
          <h1 className="text-3xl font-bold text-foreground">Consulter un Dossier</h1>
          <p className="text-muted-foreground mt-1">
            Scannez le QR code de la maman pour accéder à son dossier complet
          </p>
        </div>

        {/* Search Section */}
        {!patient && (
          <div className="max-w-2xl mx-auto animate-slide-up delay-100">
            <div className="bg-card rounded-3xl border border-border/50 p-8 shadow-xl">
              <div className="text-center mb-8">
                <div className="w-20 h-20 rounded-2xl gradient-primary flex items-center justify-center mx-auto mb-4 shadow-lg shadow-primary/30">
                  <ScanLine className="w-10 h-10 text-white" />
                </div>
                <h2 className="text-xl font-bold mb-2">Scanner le QR Code</h2>
                <p className="text-muted-foreground">
                  La maman vous présente sa carte, scannez-la pour voir son dossier
                </p>
              </div>

              <div className="space-y-4">
                <div className="flex gap-3">
                  <div className="relative flex-1">
                    <QrCode className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                    <Input
                      placeholder="Entrez le code QR (ex: QR-FKAX2Z88)"
                      value={qrCode}
                      onChange={(e) => setQrCode(e.target.value)}
                      className="pl-12 h-14 rounded-xl bg-muted/50 border-border/50 text-lg"
                      onKeyDown={(e) => e.key === "Enter" && handleSearch()}
                    />
                  </div>
                  <Button 
                    onClick={handleSearch}
                    className="h-14 px-6 rounded-xl"
                    disabled={isScanning}
                  >
                    <Search className="w-5 h-5" />
                  </Button>
                </div>

                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-border"></div>
                  </div>
                  <div className="relative flex justify-center text-xs uppercase">
                    <span className="bg-card px-2 text-muted-foreground">ou</span>
                  </div>
                </div>

                <Button 
                  onClick={handleScan}
                  variant="outline"
                  className="w-full h-14 rounded-xl text-lg"
                  disabled={isScanning}
                >
                  {isScanning ? (
                    <div className="flex items-center gap-2">
                      <div className="w-5 h-5 border-2 border-primary/30 border-t-primary rounded-full animate-spin" />
                      Scan en cours...
                    </div>
                  ) : (
                    <>
                      <ScanLine className="mr-2 w-5 h-5" />
                      Ouvrir le scanner
                    </>
                  )}
                </Button>

                {error && (
                  <div className="flex items-center gap-2 text-rose-600 bg-rose-50 dark:bg-rose-950/30 p-4 rounded-xl">
                    <AlertCircle className="w-5 h-5" />
                    <span>{error}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Patient Data */}
        {patient && (
          <div className="animate-slide-up">
            {/* Patient Header */}
            <div className="bg-gradient-to-br from-primary via-primary/95 to-emerald-700 rounded-3xl p-6 mb-6 text-white relative overflow-hidden">
              <div className="absolute inset-0 pattern-dots opacity-20" />
              <div className="absolute -right-20 -top-20 w-60 h-60 bg-white/10 rounded-full blur-3xl" />
              
              <div className="relative flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur-xl flex items-center justify-center text-2xl font-bold">
                    {patient.full_name.charAt(0)}
                  </div>
                  <div>
                    <h2 className="text-2xl font-bold">{patient.full_name}</h2>
                    <div className="flex items-center gap-3 text-white/80 text-sm mt-1">
                      <span className="flex items-center gap-1">
                        <QrCode className="w-4 h-4" />
                        {patient.qr_code}
                      </span>
                      <span>•</span>
                      <span>{patient.age} ans</span>
                      <span>•</span>
                      <span>Groupe {patient.blood_group}</span>
                    </div>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <Button 
                    variant="secondary" 
                    className="bg-white/20 text-white hover:bg-white/30 rounded-xl"
                    onClick={() => setPatient(null)}
                  >
                    Nouveau scan
                  </Button>
                </div>
              </div>

              {/* Pregnancy Info */}
              {patient.current_pregnancy && (
                <div className="mt-6 p-4 rounded-2xl bg-white/10 backdrop-blur-xl">
                  <div className="flex items-center gap-2 mb-3">
                    <Baby className="w-5 h-5" />
                    <span className="font-semibold">Grossesse n°{patient.current_pregnancy.numero} en cours</span>
                  </div>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                    <div>
                      <span className="text-white/60">Semaine</span>
                      <p className="font-bold text-lg">{patient.current_pregnancy.semaine} SA</p>
                    </div>
                    <div>
                      <span className="text-white/60">DDR</span>
                      <p className="font-semibold">{new Date(patient.current_pregnancy.date_derniere_regles).toLocaleDateString("fr-FR")}</p>
                    </div>
                    <div>
                      <span className="text-white/60">DPA</span>
                      <p className="font-semibold">{new Date(patient.current_pregnancy.date_accouchement_prevue).toLocaleDateString("fr-FR")}</p>
                    </div>
                    <div>
                      <span className="text-white/60">Trimestre</span>
                      <p className="font-bold text-lg">2ème</p>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Tabs */}
            <Tabs defaultValue="consultations" className="space-y-6">
              <TabsList className="bg-muted/50 p-1 rounded-2xl h-auto flex-wrap">
                <TabsTrigger value="consultations" className="rounded-xl py-3 px-6 data-[state=active]:bg-primary data-[state=active]:text-white">
                  <ClipboardCheck className="w-4 h-4 mr-2" />
                  CPN ({patient.consultations.length})
                </TabsTrigger>
                <TabsTrigger value="vaccinations" className="rounded-xl py-3 px-6 data-[state=active]:bg-primary data-[state=active]:text-white">
                  <Syringe className="w-4 h-4 mr-2" />
                  Vaccinations
                </TabsTrigger>
                <TabsTrigger value="treatments" className="rounded-xl py-3 px-6 data-[state=active]:bg-primary data-[state=active]:text-white">
                  <Pill className="w-4 h-4 mr-2" />
                  Traitements
                </TabsTrigger>
                <TabsTrigger value="appointments" className="rounded-xl py-3 px-6 data-[state=active]:bg-primary data-[state=active]:text-white">
                  <CalendarDays className="w-4 h-4 mr-2" />
                  RDV
                </TabsTrigger>
                <TabsTrigger value="info" className="rounded-xl py-3 px-6 data-[state=active]:bg-primary data-[state=active]:text-white">
                  <User className="w-4 h-4 mr-2" />
                  Infos
                </TabsTrigger>
              </TabsList>

              {/* Consultations Tab */}
              <TabsContent value="consultations" className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold">Consultations Prénatales</h3>
                  <Button className="rounded-xl">
                    <Plus className="w-4 h-4 mr-2" />
                    Nouvelle CPN
                  </Button>
                </div>
                
                <div className="grid gap-4">
                  {patient.consultations.map((cpn) => (
                    <div key={cpn.id} className="bg-card rounded-2xl border border-border/50 p-5 hover:border-primary/30 transition-colors">
                      <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center gap-3">
                          <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                            <span className="text-primary font-bold">CPN {cpn.cpn}</span>
                          </div>
                          <div>
                            <p className="font-semibold">Consultation n°{cpn.cpn}</p>
                            <p className="text-sm text-muted-foreground">
                              {new Date(cpn.date).toLocaleDateString("fr-FR")} • Semaine {cpn.semaine}
                            </p>
                          </div>
                        </div>
                        <Button variant="ghost" size="sm" className="rounded-lg">
                          <ChevronRight className="w-5 h-5" />
                        </Button>
                      </div>
                      
                      <div className="grid grid-cols-3 gap-4">
                        <div className="p-3 rounded-xl bg-muted/50">
                          <p className="text-xs text-muted-foreground">Poids</p>
                          <p className="font-bold">{cpn.poids} kg</p>
                        </div>
                        <div className="p-3 rounded-xl bg-muted/50">
                          <p className="text-xs text-muted-foreground">Tension</p>
                          <p className="font-bold">{cpn.tension}</p>
                        </div>
                        <div className="p-3 rounded-xl bg-muted/50">
                          <p className="text-xs text-muted-foreground">Notes</p>
                          <p className="font-medium text-sm truncate">{cpn.notes}</p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </TabsContent>

              {/* Vaccinations Tab */}
              <TabsContent value="vaccinations" className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold">Vaccinations</h3>
                  <Button className="rounded-xl">
                    <Plus className="w-4 h-4 mr-2" />
                    Ajouter vaccination
                  </Button>
                </div>
                
                <div className="grid gap-3">
                  {patient.vaccinations.map((vax) => (
                    <div key={vax.id} className="bg-card rounded-2xl border border-border/50 p-4 flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${
                          vax.done ? "bg-emerald-500/10" : "bg-amber-500/10"
                        }`}>
                          <Syringe className={`w-6 h-6 ${vax.done ? "text-emerald-600" : "text-amber-600"}`} />
                        </div>
                        <div>
                          <p className="font-semibold">{vax.name}</p>
                          <p className="text-sm text-muted-foreground">
                            {new Date(vax.date).toLocaleDateString("fr-FR")}
                          </p>
                        </div>
                      </div>
                      <Badge className={`rounded-full ${
                        vax.done 
                          ? "bg-emerald-500/10 text-emerald-600" 
                          : "bg-amber-500/10 text-amber-600"
                      }`}>
                        {vax.done ? (
                          <><CheckCircle2 className="w-3 h-3 mr-1" /> Effectuée</>
                        ) : (
                          <><Calendar className="w-3 h-3 mr-1" /> Programmée</>
                        )}
                      </Badge>
                    </div>
                  ))}
                </div>
              </TabsContent>

              {/* Treatments Tab */}
              <TabsContent value="treatments" className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold">Traitements en cours</h3>
                  <Button className="rounded-xl">
                    <Plus className="w-4 h-4 mr-2" />
                    Prescrire
                  </Button>
                </div>
                
                <div className="grid gap-3">
                  {patient.treatments.map((treatment) => (
                    <div key={treatment.id} className="bg-card rounded-2xl border border-border/50 p-4 flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-xl bg-blue-500/10 flex items-center justify-center">
                          <Pill className="w-6 h-6 text-blue-600" />
                        </div>
                        <div>
                          <p className="font-semibold">{treatment.name}</p>
                          <p className="text-sm text-muted-foreground">{treatment.dosage}</p>
                        </div>
                      </div>
                      <Badge className="rounded-full bg-emerald-500/10 text-emerald-600">
                        <CheckCircle2 className="w-3 h-3 mr-1" /> Actif
                      </Badge>
                    </div>
                  ))}
                </div>
              </TabsContent>

              {/* Appointments Tab */}
              <TabsContent value="appointments" className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold">Prochains rendez-vous</h3>
                  <Button className="rounded-xl">
                    <Plus className="w-4 h-4 mr-2" />
                    Planifier RDV
                  </Button>
                </div>
                
                <div className="grid gap-3">
                  {patient.appointments.map((rdv) => (
                    <div key={rdv.id} className="bg-card rounded-2xl border border-border/50 p-4 flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center">
                          <CalendarDays className="w-6 h-6 text-purple-600" />
                        </div>
                        <div>
                          <p className="font-semibold">{rdv.type}</p>
                          <p className="text-sm text-muted-foreground">
                            {new Date(rdv.date).toLocaleDateString("fr-FR")} à {rdv.heure}
                          </p>
                        </div>
                      </div>
                      <Button variant="outline" size="sm" className="rounded-lg">
                        Modifier
                      </Button>
                    </div>
                  ))}
                </div>
              </TabsContent>

              {/* Info Tab */}
              <TabsContent value="info" className="space-y-4">
                <div className="grid md:grid-cols-2 gap-6">
                  {/* Patient Info */}
                  <div className="bg-card rounded-2xl border border-border/50 p-6">
                    <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                      <User className="w-5 h-5 text-primary" />
                      Informations personnelles
                    </h3>
                    <div className="space-y-4">
                      <div className="flex items-center gap-3">
                        <Phone className="w-5 h-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm text-muted-foreground">Téléphone</p>
                          <p className="font-medium">{patient.phone}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <MapPin className="w-5 h-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm text-muted-foreground">Adresse</p>
                          <p className="font-medium">{patient.address}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <Calendar className="w-5 h-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm text-muted-foreground">Date de naissance</p>
                          <p className="font-medium">{new Date(patient.birth_date).toLocaleDateString("fr-FR")}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <Stethoscope className="w-5 h-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm text-muted-foreground">Profession</p>
                          <p className="font-medium">{patient.profession}</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Spouse Info */}
                  <div className="bg-card rounded-2xl border border-border/50 p-6">
                    <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                      <Heart className="w-5 h-5 text-rose-500" />
                      Informations du conjoint
                    </h3>
                    <div className="space-y-4">
                      <div className="flex items-center gap-3">
                        <User className="w-5 h-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm text-muted-foreground">Nom</p>
                          <p className="font-medium">{patient.spouse.name}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <Phone className="w-5 h-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm text-muted-foreground">Téléphone</p>
                          <p className="font-medium">{patient.spouse.phone}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <Heart className="w-5 h-5 text-muted-foreground" />
                        <div>
                          <p className="text-sm text-muted-foreground">Groupe sanguin</p>
                          <p className="font-medium">{patient.spouse.blood_group}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </TabsContent>
            </Tabs>
          </div>
        )}
      </main>
    </div>
  );
};

export default ConsultRecord;

