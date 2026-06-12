/* ================== EMPRESAS SEMILLA ================== */
/* En modo memoria el id coincide con el slug; en Supabase son uuid. */

export const PERKS_DEFAULT = [
  "✨ Desarrollo profesional",
  "🎓 Capacitación continua",
  "🛍️ Descuentos para empleados",
  "🤝 Excelente ambiente",
  "🚀 Crecimiento",
  "💡 Cultura creativa",
];

export const COMPANIES_INIT = [
  {
    id:"thew", name:"The W", slug:"thew",
    tagline:"Moda hecha en Medellín. Únete al equipo.",
    color:"#B5121B", // acento (rojo oscuro); la base visual pública es negro profundo
    email:"talento@thew.co", city:"Medellín, Colombia",
    industry:"Moda y diseño", teamSize:"50–100 personas", website:"thew.co",
    heroImageUrl:"", heroPhrase:"Hecho en Medellín. Pensado para el mundo.",
    mission:"Diseñamos prendas que nacen de una idea, evolucionan con creatividad y terminan convirtiéndose en identidad para quienes las usan. Creemos en el detalle, en la autenticidad y en el talento que transforma conceptos en experiencias. Cada colección representa una visión contemporánea de la moda hecha en Medellín con proyección internacional. Si compartes nuestra pasión por crear, aprender y construir marcas memorables, queremos conocerte.",
    whyJoin:"En The W creemos que la moda es una forma de expresión y que detrás de cada prenda existe un equipo comprometido con la creatividad, la excelencia y la innovación. Promovemos un ambiente donde las ideas tienen espacio para crecer, el talento es reconocido y cada integrante puede aportar una visión única. Buscamos personas apasionadas por aprender, colaborar y construir una marca con propósito.",
    perks: PERKS_DEFAULT,
    footerTagline:"Moda con propósito. Diseñada en Medellín. Inspirada por las personas.",
  },
  {
    id:"pingpongburger", name:"PingPong Burger", slug:"pingpongburger",
    tagline:"Hamburguesas con juego limpio.",
    color:"#F2540B",
    email:"seleccion@pingpongburger.co", city:"Medellín, Colombia",
    industry:"Restaurantes", teamSize:"20–50 personas", website:"pingpongburger.co",
    heroImageUrl:"", heroPhrase:"Sabor que juega en serio.",
    mission:"Hacemos hamburguesas con ingredientes honestos y un servicio que se siente como jugar en casa. Crecemos sede a sede con equipos que disfrutan el ritmo del servicio y el trabajo bien hecho. Si te gusta la buena cocina y el buen ambiente, este es tu lugar.",
    whyJoin:"Somos un equipo cercano donde el esfuerzo se nota y se reconoce. Aquí aprendes el oficio de verdad, creces a tu ritmo y trabajas con personas que disfrutan lo que hacen.",
    perks: PERKS_DEFAULT,
    footerTagline:"Hamburguesas con juego limpio. Hechas en Medellín.",
  },
];
