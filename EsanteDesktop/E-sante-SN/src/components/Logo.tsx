import logoImage from "@/assets/image/logo.png";

const Logo = ({ className = "" }: { className?: string }) => {
  return (
    <div className={`flex items-center ${className}`}>
      <img 
        src={logoImage} 
        alt="E-SANTÉ SÉNÉGAL" 
        className="h-16 w-auto object-contain"
      />
    </div>
  );
};

export default Logo;
