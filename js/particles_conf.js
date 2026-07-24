/* particles.js background — Vincent Garreau particles.js (MIT)
   Colours match site palette (terracotta / ochre).
   Container is pointer-events: none so content stays clickable.
   https://github.com/VincentGarreau/particles.js
*/
(function () {
  function initParticles() {
    if (typeof window.particlesJS !== 'function') {
      console.warn('particles.js: library not loaded');
      return;
    }

    var host = document.getElementById('particles-js');
    if (!host) {
      console.warn('particles.js: #particles-js container missing');
      return;
    }

    // Honour prefers-reduced-motion: leave a static empty layer (no animation)
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      host.setAttribute('data-particles', 'reduced-motion');
      return;
    }

    // Ensure the fixed host has measurable box before canvas init
    host.style.width = '100%';
    host.style.height = '100%';
    host.style.minHeight = '100vh';

    window.particlesJS('particles-js', {
      particles: {
        number: { value: 70, density: { enable: true, value_area: 800 } },
        color: { value: '#C65D3B' },
        shape: {
          type: 'circle',
          stroke: { width: 0, color: '#000000' }
        },
        opacity: {
          value: 0.55,
          random: true,
          anim: { enable: false, speed: 1, opacity_min: 0.25, sync: false }
        },
        size: {
          value: 4,
          random: true,
          anim: { enable: false, speed: 20, size_min: 1, sync: false }
        },
        line_linked: {
          enable: true,
          distance: 150,
          color: '#E07A3D',
          opacity: 0.4,
          width: 1.2
        },
        move: {
          enable: true,
          speed: 2,
          direction: 'none',
          random: true,
          straight: false,
          out_mode: 'out',
          bounce: false,
          attract: { enable: false, rotateX: 600, rotateY: 1200 }
        }
      },
      interactivity: {
        detect_on: 'canvas',
        events: {
          onhover: { enable: false, mode: 'repulse' },
          onclick: { enable: false, mode: 'push' },
          resize: true
        },
        modes: {
          grab: { distance: 400, line_linked: { opacity: 1 } },
          bubble: { distance: 400, size: 40, duration: 2, opacity: 8, speed: 3 },
          repulse: { distance: 200, duration: 0.4 },
          push: { particles_nb: 4 },
          remove: { particles_nb: 2 }
        }
      },
      retina_detect: true
    });

    host.setAttribute('data-particles', 'active');
  }

  // defer scripts run after parse; still gate on readyState for safety
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initParticles);
  } else {
    initParticles();
  }
})();
