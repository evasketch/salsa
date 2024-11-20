import React, { useState, useEffect, useRef } from 'react';
import { Timer, User, ThumbsUp, Bell, History, MessageCircle, Pause, Play } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';

const DEFAULT_SESSION_TIME = 25 * 60; // 25 minutes in seconds

const BodyDoubleApp = () => {
  const [isWorking, setIsWorking] = useState(false);
  const [timer, setTimer] = useState(DEFAULT_SESSION_TIME);
  const [isPaused, setIsPaused] = useState(false);
  const [status, setStatus] = useState('');
  const [sessions, setSessions] = useState([
    {
      id: 1,
      userId: 'friend',
      startTime: new Date(Date.now() - 3600000).toISOString(),
      endTime: new Date(Date.now() - 3300000).toISOString(),
      status: 'Completed',
      task: 'Writing documentation',
      acknowledged: false
    }
  ]);

  const [friendSession, setFriendSession] = useState(null);
  const audioRef = useRef(null);

  useEffect(() => {
    let interval;
    if (isWorking && !isPaused) {
      interval = setInterval(() => {
        setTimer(prev => {
          if (prev <= 1) {
            // Time's up!
            playAlarm();
            clearInterval(interval);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isWorking, isPaused]);

  const playAlarm = () => {
    if (audioRef.current) {
      audioRef.current.play();
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const startSession = () => {
    if (!status.trim()) {
      setStatus("Focused Work Session");
    }
    setTimer(DEFAULT_SESSION_TIME);
    setIsWorking(true);
    setIsPaused(false);
  };

  const pauseSession = () => {
    setIsPaused(true);
  };

  const resumeSession = () => {
    setIsPaused(false);
  };

  const endSession = () => {
    setIsWorking(false);
    setIsPaused(false);
    setSessions(prev => [...prev, {
      id: Date.now(),
      userId: 'me',
      startTime: new Date(Date.now() - (DEFAULT_SESSION_TIME - timer) * 1000).toISOString(),
      endTime: new Date().toISOString(),
      status: 'Completed',
      task: status,
      acknowledged: false
    }]);
    setTimer(DEFAULT_SESSION_TIME);
    setStatus('');
  };

  const acknowledgeSession = (sessionId) => {
    setSessions(prev => prev.map(session => 
      session.id === sessionId 
        ? { ...session, acknowledged: true }
        : session
    ));
  };

  const joinSession = () => {
    if (friendSession) {
      setStatus(`Joining ${friendSession.task}`);
      startSession();
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleString();
  };

  return (
    <div className="max-w-4xl mx-auto p-4 space-y-4">
      {/* Audio element for alarm */}
      <audio ref={audioRef}>
        <source src="/api/placeholder/audio" type="audio/mp3" />
      </audio>

      {/* Quick Start Card */}
      <Card className="bg-white">
        <CardContent className="pt-6">
          <div className="flex flex-col space-y-4">
            {!isWorking ? (
              <>
                <input
                  type="text"
                  placeholder="What are you working on? (optional)"
                  value={status}
                  onChange={(e) => setStatus(e.target.value)}
                  className="px-4 py-2 border rounded-lg"
                />
                <button
                  onClick={startSession}
                  className="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg font-semibold text-lg"
                >
                  Start 25min Session
                </button>
              </>
            ) : (
              <div className="flex flex-col items-center space-y-4">
                <div className="text-4xl font-mono font-bold">{formatTime(timer)}</div>
                <div className="text-lg font-medium">{status}</div>
                <div className="flex space-x-4">
                  {!isPaused ? (
                    <button
                      onClick={pauseSession}
                      className="bg-yellow-500 hover:bg-yellow-600 text-white px-6 py-3 rounded-lg font-semibold flex items-center gap-2"
                    >
                      <Pause size={20} /> Pause
                    </button>
                  ) : (
                    <button
                      onClick={resumeSession}
                      className="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg font-semibold flex items-center gap-2"
                    >
                      <Play size={20} /> Resume
                    </button>
                  )}
                  <button
                    onClick={endSession}
                    className="bg-red-500 hover:bg-red-600 text-white px-6 py-3 rounded-lg font-semibold"
                  >
                    End Session
                  </button>
                </div>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Friend's Active Session Card */}
      {friendSession && (
        <Card className="bg-green-50">
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <span>Friend is currently working!</span>
              <button
                onClick={joinSession}
                className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg text-sm"
              >
                Join Session
              </button>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-gray-600">
              Working on: {friendSession.task}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Session History */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <History size={20} />
            Session History
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {sessions.map(session => (
              <div key={session.id} className="border rounded-lg p-4 flex justify-between items-center">
                <div className="space-y-1">
                  <div className="font-medium">{session.task}</div>
                  <div className="text-sm text-gray-500">
                    {formatDate(session.startTime)} - {formatDate(session.endTime)}
                  </div>
                  <div className="text-sm">
                    By: {session.userId === 'me' ? 'You' : 'Friend'}
                  </div>
                </div>
                {session.userId !== 'me' && !session.acknowledged && (
                  <button
                    onClick={() => acknowledgeSession(session.id)}
                    className="flex items-center gap-2 bg-gray-100 hover:bg-gray-200 px-4 py-2 rounded-lg"
                  >
                    <ThumbsUp size={16} />
                    Acknowledge
                  </button>
                )}
                {session.acknowledged && (
                  <div className="text-green-500 flex items-center gap-2">
                    <ThumbsUp size={16} />
                    Acknowledged
                  </div>
                )}
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default BodyDoubleApp;
