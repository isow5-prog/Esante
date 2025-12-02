import { 
  Bell, LayoutDashboard, QrCode, Home, ClipboardCheck, 
  FilePlus, Menu, Users, BarChart3, MessageSquare, 
  LogOut, User, ChevronDown, Shield, ScanLine
} from "lucide-react";
import { useLocation, useNavigate } from "react-router-dom";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { NavLink } from "./NavLink";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import Logo from "./Logo";
import { cn } from "@/lib/utils";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface HeaderProps {
  showLogo?: boolean;
  actions?: React.ReactNode;
}

const Header = ({ showLogo = true, actions }: HeaderProps) => {
  const location = useLocation();
  const navigate = useNavigate();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Déterminer le type d'utilisateur basé sur la route
  const ministryRoutes = ["/dashboard", "/qr-generation", "/mothers-list", "/users", "/statistics", "/messages", "/add-center"];
  const midwifeRoutes = ["/home", "/validate-card", "/add-record"];
  
  const isMinistry = ministryRoutes.some(route => location.pathname.startsWith(route));
  const isMidwife = midwifeRoutes.some(route => location.pathname.startsWith(route));

  // Liens pour le ministère
  const ministryLinks = [
    { to: "/dashboard", label: "Accueil", icon: LayoutDashboard },
    { to: "/qr-generation", label: "QR Codes", icon: QrCode },
    { to: "/mothers-list", label: "Mères", icon: Users },
    { to: "/users", label: "Utilisateurs", icon: ClipboardCheck },
    { to: "/statistics", label: "Statistiques", icon: BarChart3 },
    { to: "/messages", label: "Messages", icon: MessageSquare },
  ];

  // Liens pour la sage-femme
  const midwifeLinks = [
    { to: "/home", label: "Accueil", icon: Home },
    { to: "/consult-record", label: "Consulter dossier", icon: ScanLine },
    { to: "/validate-card", label: "Valider une carte", icon: ClipboardCheck },
    { to: "/add-record", label: "Ajouter un carnet", icon: FilePlus },
  ];

  const links = isMinistry ? ministryLinks : isMidwife ? midwifeLinks : [];
  const userRole = isMinistry ? "Ministère de la Santé" : "Agent de Santé";
  const userName = isMinistry ? "Admin Ministère" : "Sage-femme";

  const NavLinks = () => (
    <>
      {links.map((link) => {
        const Icon = link.icon;
        const isActive = location.pathname === link.to;
        
        return (
          <NavLink
            key={link.to}
            to={link.to}
            onClick={() => setMobileMenuOpen(false)}
            className={cn(
              "flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 whitespace-nowrap",
              isActive
                ? "bg-primary text-white shadow-lg shadow-primary/25"
                : "text-foreground/70 hover:text-foreground hover:bg-muted"
            )}
          >
            <Icon className="w-4 h-4" />
            {link.label}
          </NavLink>
        );
      })}
    </>
  );

  return (
    <header className="sticky top-0 z-50 bg-card/80 backdrop-blur-xl border-b border-border/50">
      <div className="max-w-7xl mx-auto px-6">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center gap-8">
            {/* Logo */}
            {showLogo && (
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl gradient-primary flex items-center justify-center shadow-lg shadow-primary/20">
                  <Shield className="w-5 h-5 text-white" />
                </div>
                <div className="hidden sm:block">
                  <div className="font-bold text-foreground">E-Santé SN</div>
                  <div className="text-xs text-muted-foreground">{userRole}</div>
                </div>
              </div>
            )}
            
            {/* Navigation desktop */}
            {links.length > 0 && (
              <nav className="hidden lg:flex items-center gap-1 bg-muted/50 p-1 rounded-2xl">
                <NavLinks />
              </nav>
            )}
          </div>
          
          <div className="flex items-center gap-3">
            {/* Notifications */}
            <Button 
              variant="ghost" 
              size="icon" 
              className="relative rounded-xl hover:bg-muted w-10 h-10"
            >
              <Bell className="w-5 h-5" />
              <span className="absolute -top-0.5 -right-0.5 w-4 h-4 bg-rose-500 rounded-full text-[10px] text-white font-bold flex items-center justify-center">
                3
              </span>
            </Button>

            {/* User Menu */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button 
                  variant="ghost" 
                  className="flex items-center gap-3 px-3 py-2 h-auto rounded-xl hover:bg-muted"
                >
                  <div className="w-9 h-9 rounded-xl gradient-primary flex items-center justify-center">
                    <User className="w-4 h-4 text-white" />
                  </div>
                  <div className="hidden md:block text-left">
                    <div className="text-sm font-medium">{userName}</div>
                    <div className="text-xs text-muted-foreground">{userRole}</div>
                  </div>
                  <ChevronDown className="w-4 h-4 text-muted-foreground hidden md:block" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56 rounded-xl p-2">
                <DropdownMenuLabel className="font-normal">
                  <div className="flex flex-col space-y-1">
                    <p className="text-sm font-medium">{userName}</p>
                    <p className="text-xs text-muted-foreground">{userRole}</p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem className="rounded-lg cursor-pointer">
                  <User className="mr-2 h-4 w-4" />
                  Mon profil
                </DropdownMenuItem>
                <DropdownMenuItem className="rounded-lg cursor-pointer">
                  <Bell className="mr-2 h-4 w-4" />
                  Notifications
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem 
                  className="rounded-lg cursor-pointer text-rose-600 focus:text-rose-600 focus:bg-rose-50"
                  onClick={() => navigate("/")}
                >
                  <LogOut className="mr-2 h-4 w-4" />
                  Déconnexion
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>

            {/* Mobile menu */}
            <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
              <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className="lg:hidden rounded-xl">
                  <Menu className="w-5 h-5" />
                </Button>
              </SheetTrigger>
              <SheetContent side="left" className="w-[280px] p-0">
                <div className="p-6 border-b border-border">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl gradient-primary flex items-center justify-center">
                      <Shield className="w-6 h-6 text-white" />
                    </div>
                    <div>
                      <div className="font-bold">E-Santé SN</div>
                      <div className="text-sm text-muted-foreground">{userRole}</div>
                    </div>
                  </div>
                </div>
                <div className="flex flex-col gap-1 p-4">
                  {links.map((link) => {
                    const Icon = link.icon;
                    const isActive = location.pathname === link.to;
                    
                    return (
                      <NavLink
                        key={link.to}
                        to={link.to}
                        onClick={() => setMobileMenuOpen(false)}
                        className={cn(
                          "flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all",
                          isActive
                            ? "bg-primary text-white"
                            : "text-foreground hover:bg-muted"
                        )}
                      >
                        <Icon className="w-5 h-5" />
                        {link.label}
                      </NavLink>
                    );
                  })}
                </div>
                <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-border">
                  <Button 
                    variant="outline" 
                    className="w-full rounded-xl text-rose-600 border-rose-200 hover:bg-rose-50"
                    onClick={() => navigate("/")}
                  >
                    <LogOut className="mr-2 w-4 h-4" />
                    Déconnexion
                  </Button>
                </div>
              </SheetContent>
            </Sheet>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
