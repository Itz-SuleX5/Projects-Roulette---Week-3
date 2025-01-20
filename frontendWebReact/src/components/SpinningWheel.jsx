import React, { useState, useRef, useEffect } from 'react';
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Menu, Languages, X } from "lucide-react";
import { Dialog, DialogContent, DialogClose } from "@/components/ui/dialog";

const SpinningWheel = () => {
  const [isSpinning, setIsSpinning] = useState(false);
  const [winner, setWinner] = useState(null);
  const [showResult, setShowResult] = useState(false);
  const [currentRotation, setCurrentRotation] = useState(0);
  const [notes, setNotes] = useState([]);
  const [language, setLanguage] = useState('es');
  const [showLanguageMenu, setShowLanguageMenu] = useState(false);
  const wheelRef = useRef(null);

  useEffect(() => {
    const fetchNotes = async () => {
      try {
        const response = await fetch('https://sticky-notes-week-1.onrender.com/api/notes');
        const data = await response.json();
        setNotes(data);
      } catch (error) {
        console.error('Error fetching notes:', error);
      }
    };

    fetchNotes();
  }, []);

  const CENTER_X = 50;
  const CENTER_Y = 50;
  const DETECTION_ANGLE = 270;
  const DETECTION_RADIUS = 45;

  const detectionX = CENTER_X + DETECTION_RADIUS * Math.cos((DETECTION_ANGLE * Math.PI) / 180);
  const detectionY = CENTER_Y + DETECTION_RADIUS * Math.sin((DETECTION_ANGLE * Math.PI) / 180);

  const colors = [
    "#FFB3BA",
    "#87CEEB",
    "#FFFFBA",
    "#FF9E80",
    "#E6B3FF",
    "#98FB98",
    "#E6B3FF",
    "#98FB98"
  ];

  const getWinningIndex = (finalRotation) => {
    let normalizedRotation = -finalRotation % 360;
    if (normalizedRotation < 0) {
      normalizedRotation += 360;
    }
    
    const effectiveAngle = (normalizedRotation + DETECTION_ANGLE) % 360;
    const sectionSize = 360 / notes.length;
    return Math.floor(effectiveAngle / sectionSize);
  };

  const spinWheel = () => {
    if (!isSpinning && wheelRef.current && notes.length > 0) {
      setIsSpinning(true);
      setShowResult(false);
      
      const minSpins = 5;
      const maxExtraSpins = 3;
      const spins = minSpins + Math.random() * maxExtraSpins;
      const extraDegrees = Math.random() * 360;
      const totalDegrees = spins * 360 + extraDegrees;
      const newRotation = currentRotation + totalDegrees;
      
      wheelRef.current.style.transition = 'none';
      wheelRef.current.style.transform = `rotate(${currentRotation}deg)`;
      
      wheelRef.current.offsetHeight;
      
      wheelRef.current.style.transition = 'transform 4s cubic-bezier(0.2, 0.8, 0.3, 1)';
      wheelRef.current.style.transform = `rotate(${newRotation}deg)`;
      
      setCurrentRotation(newRotation);
      
      const winningIndex = getWinningIndex(newRotation);
      const finalWinner = notes[winningIndex];

      setTimeout(() => {
        setIsSpinning(false);
        setWinner(finalWinner);
        setShowResult(true);
      }, 3800);
    }
  };

  const translations = {
    es: {
      loading: 'Cargando notas...',
      spinning: 'Girando...',
      tapToSpin: 'Toca la rueda para girar',
      result: '¡Resultado!',
      home: 'Home',
      history: 'Historial',
      english: 'Inglés',
      spanish: 'Español',
      title: 'Ruleta de Proyectos'
    },
    en: {
      loading: 'Loading notes...',
      spinning: 'Spinning...',
      tapToSpin: 'Tap wheel to spin',
      result: 'Result!',
      home: 'Home',
      history: 'History',
      english: 'English',
      spanish: 'Spanish',
      title: 'Projects Roulette'
    }
  };

  const t = translations[language];

  if (notes.length === 0) {
    return <div className="min-h-screen bg-white flex items-center justify-center">
      <p className="text-black">{t.loading}</p>
    </div>;
  }

  return (
    <div className="min-h-screen bg-white flex">
      <Sheet>
        <SheetTrigger asChild>
          <Button variant="ghost" className="fixed top-4 left-4 bg-white hover:bg-gray-100">
            <Menu className="h-6 w-6 text-black" />
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-64 bg-white">
          <nav className="space-y-4 mt-8">
            <Button variant="ghost" className="w-full justify-start bg-white hover:bg-gray-100 text-black">
              {t.home}
            </Button>
            <Button variant="ghost" className="w-full justify-start bg-white hover:bg-gray-100 text-black">
              {t.history}
            </Button>
            <div className="relative">
              <Button
                variant="ghost"
                className="w-full justify-start bg-white hover:bg-gray-100 text-black"
                onClick={() => setShowLanguageMenu(!showLanguageMenu)}
              >
                <Languages className="h-6 w-6 mr-2" />
                {language === 'es' ? t.spanish : t.english}
              </Button>
              {showLanguageMenu && (
                <div className="absolute top-full left-0 w-full bg-white border rounded-md shadow-lg mt-1 z-50 overflow-hidden">
                  <Button
                    variant="ghost"
                    className="w-full justify-start bg-white hover:bg-gray-100 text-black"
                    onClick={() => {
                      setLanguage('en');
                      setShowLanguageMenu(false);
                    }}
                  >
                    {t.english}
                  </Button>
                  <Button
                    variant="ghost"
                    className="w-full justify-start bg-white hover:bg-gray-100 text-black"
                    onClick={() => {
                      setLanguage('es');
                      setShowLanguageMenu(false);
                    }}
                  >
                    {t.spanish}
                  </Button>
                </div>
              )}
            </div>
          </nav>
        </SheetContent>
      </Sheet>

      <div className="flex-1 flex flex-col items-center justify-center p-8">
        <h1 className="text-3xl font-bold text-black mb-8">{t.title}</h1>
        <div className="relative w-96 h-96 mb-8">
          <div 
            className="absolute w-6 h-8 z-10"
            style={{
              left: `${(detectionX / 100) * 100}%`,
              top: `${(detectionY / 100) * 100}%`,
              transform: 'translate(-50%, -100%) rotate(180deg)'
            }}
          >
            <svg viewBox="0 0 24 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 0L24 32L12 24L0 32L12 0Z" fill="black"/>
            </svg>
          </div>
          
          <svg
            ref={wheelRef}
            className="w-full h-full cursor-pointer border-2 border-gray-200 rounded-full"
            viewBox="0 0 100 100"
            onClick={spinWheel}
            style={{
              transformOrigin: '50% 50%',
              transition: 'transform 4s cubic-bezier(0.2, 0.8, 0.3, 1)',
              backgroundColor: 'white',
            }}
          >
            {notes.map((note, index) => {
              const angle = (360 / notes.length) * index;
              const angleRad = (angle * Math.PI) / 180;
              const nextAngleRad = ((angle + 360 / notes.length) * Math.PI) / 180;
              
              const radius = 45;
              
              const x1 = CENTER_X + radius * Math.cos(angleRad);
              const y1 = CENTER_Y + radius * Math.sin(angleRad);
              const x2 = CENTER_X + radius * Math.cos(nextAngleRad);
              const y2 = CENTER_Y + radius * Math.sin(nextAngleRad);
              
              const textAngle = angle + (360 / notes.length) / 2;
              const textAngleRad = (textAngle * Math.PI) / 180;
              const textRadius = radius * 0.65;
              const textX = CENTER_X + textRadius * Math.cos(textAngleRad);
              const textY = CENTER_Y + textRadius * Math.sin(textAngleRad);

              let textRotation = textAngle;
              if (textAngle > 90 && textAngle <= 270) {
                textRotation += 180;
              }

              return (
                <g key={note._id}>
                  <path
                    d={`M ${CENTER_X} ${CENTER_Y} L ${x1} ${y1} A ${radius} ${radius} 0 0 1 ${x2} ${y2} Z`}
                    fill={colors[index % colors.length]}
                    stroke="white"
                    strokeWidth="0.5"
                  />
                  <text
                    x={textX}
                    y={textY}
                    fill="black"
                    fontSize="2.5"
                    textAnchor="middle"
                    dominantBaseline="middle"
                    transform={`rotate(${textRotation}, ${textX}, ${textY})`}
                    style={{
                      userSelect: 'none',
                      fontWeight: 'bold'
                    }}
                  >
                    {note.title.length > 15 ? note.title.substring(0, 15) + '...' : note.title}
                  </text>
                </g>
              );
            })}
            <circle
              cx={CENTER_X}
              cy={CENTER_Y}
              r="3"
              fill="black"
              stroke="white"
              strokeWidth="0.5"
            />
          </svg>
        </div>
        
        <p className="text-gray-600 mt-4">
          {isSpinning ? t.spinning : t.tapToSpin}
        </p>

        <Dialog open={showResult} onOpenChange={setShowResult}>
          <DialogContent className="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[425px] bg-white rounded-lg shadow-lg p-6">
            <div className="relative">
              <DialogClose className="absolute -top-1 -right-1 bg-white hover:bg-gray-100 rounded-full p-1">
                <X className="h-5 w-5 text-gray-500" />
              </DialogClose>
              <div className="text-center mt-2">
                <h2 className="text-xl font-semibold mb-4 text-black">{t.result}</h2>
                <p className="text-lg font-medium text-black mb-3">{winner?.title}</p>
                <p className="text-gray-600">{winner?.description}</p>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
};

export default SpinningWheel;