package io.privacy.anom.vpn;



import androidx.annotation.NonNull;
import android.util.Log;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;

class VpnWatchdog {
    private static final String TAG = "VpnWatchDog";

    // Polling is quadrupled on every success, and values range from 4s to 1h8m.
    private static final int POLL_TIMEOUT_START = 1000;
    private static final int POLL_TIMEOUT_END = 4096000;
    private static final int POLL_TIMEOUT_WAITING = 7000;
    private static final int POLL_TIMEOUT_GROW = 4;

    // Reconnect penalty ranges from 0s to 5s, in increments of 200 ms.
    private static final int INIT_PENALTY_START = 0;
    private static final int INIT_PENALTY_END = 5000;
    private static final int INIT_PENALTY_INC = 200;

    int initPenalty = INIT_PENALTY_START;
    int pollTimeout = POLL_TIMEOUT_START;

    // Information about when packets where received.
    long lastPacketSent = 0;
    long lastPacketReceived = 0;

    private boolean enabled = false;
    private InetAddress target;


    /**
     * Returns the current poll time out.
     */
    int getPollTimeout() {
        if (!enabled)
            return -1;
        if (lastPacketReceived < lastPacketSent)
            return POLL_TIMEOUT_WAITING;
        return pollTimeout;
    }

    /**
     * Sets the target address ping packets should be sent to.
     */
    void setTarget(InetAddress target) {
        this.target = target;
    }


    void initialize(boolean enabled) throws InterruptedException {
        Log.d(TAG, "initialize: Initializing watchdog");

        pollTimeout = POLL_TIMEOUT_START;
        lastPacketSent = 0;
        this.enabled = enabled;

        if (!enabled) {
            Log.d(TAG, "initialize: Disabled.");
            return;
        }

        if (initPenalty > 0) {
            Log.d(TAG, "init penalty: Sleeping for " + initPenalty + "ms");
            Thread.sleep(initPenalty);
        }
    }

    /**
     * Handles a timeout of poll()
     *
     * @throws AnomVPNThread.VpnNetworkException When the watchdog timed out
     */
    void handleTimeout() throws AnomVPNThread.VpnNetworkException {
        if (!enabled)
            return;
        Log.d(TAG, "handleTimeout: Milliseconds elapsed between last receive and sent: "
                + (lastPacketReceived - lastPacketSent));
        // Receive really timed out.
        if (lastPacketReceived < lastPacketSent && lastPacketSent != 0) {
            initPenalty += INIT_PENALTY_INC;
            if (initPenalty > INIT_PENALTY_END)
                initPenalty = INIT_PENALTY_END;
            throw new AnomVPNThread.VpnNetworkException("Watchdog timed out");
        }
        // We received a packet after sending it, so we can be more confident and grow our wait
        // time.
        pollTimeout *= POLL_TIMEOUT_GROW;
        if (pollTimeout > POLL_TIMEOUT_END)
            pollTimeout = POLL_TIMEOUT_END;


        sendPacket();
    }

    /**
     * Handles an incoming packet on a device.
     *
     * @param packetData The data of the packet
     */
    void handlePacket(byte[] packetData) {
        if (!enabled)
            return;

        Log.d(TAG, "handlePacket: Received packet of length " + packetData.length);
        lastPacketReceived = System.currentTimeMillis();
    }

    /**
     * Sends an empty check-alive packet to the configured target address.
     *
     * @throws AnomVPNThread.VpnNetworkException If sending failed and we should restart
     */
    void sendPacket() throws AnomVPNThread.VpnNetworkException {
        if (!enabled)
            return;

        Log.d(TAG, "sendPacket: Sending packet, poll timeout is " + pollTimeout);

        DatagramPacket outPacket = new DatagramPacket(new byte[0], 0, 0 /* length */, target, 53);
        try {
            DatagramSocket socket = newDatagramSocket();
            socket.send(outPacket);
            socket.close();
            lastPacketSent = System.currentTimeMillis();
        } catch (IOException e) {
            throw new AnomVPNThread.VpnNetworkException("Received exception", e);
        }
    }

    @NonNull
    DatagramSocket newDatagramSocket() throws SocketException {
        return new DatagramSocket();
    }
}
