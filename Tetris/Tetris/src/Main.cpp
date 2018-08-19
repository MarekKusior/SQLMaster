#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <iostream>
using namespace std;

const int width = 640;
const int height = 480;

const int M = 20;
const int N = 10;

int field[M][N] = {0};

struct Point
{int x,y;} a[4], b[4];

int figures[7][4] =
{
	1,3,5,7, // I
	2,4,5,7, // Z
	3,5,4,6, // S
	3,5,4,7, // T
	2,3,5,7, // L
	3,5,7,6, // J
	2,3,4,5, // O
};

int main()
{
    al_init();
    al_install_keyboard();
    al_init_image_addon();

    ALLEGRO_KEYBOARD_STATE kayboard;
    ALLEGRO_DISPLAY *display  = al_create_display(width, height);
    al_set_window_title( display,"Bitmapy");

    ALLEGRO_BITMAP *tile = al_load_bitmap("images/tiles.png");//Wczytywanie obrazka
    ALLEGRO_EVENT_QUEUE *event_queue = al_create_event_queue();

    al_register_event_source(event_queue, al_get_display_event_source(display));
    ALLEGRO_EVENT event;

    int sw = 18;
    int sh = 18;

    while(!al_key_down(&kayboard, ALLEGRO_KEY_ESCAPE))
    {
        al_get_next_event(event_queue, &event);

        if(event.type == ALLEGRO_EVENT_DISPLAY_CLOSE) return 0;

        //al_get_keyboard_state(&kayboard);
        al_clear_to_color(al_map_rgb(255,255,255));//kolor okna
        //al_draw_pixel( 5, 5, al_map_rgb(255,255,255));
        //al_draw_bitmap_region(tile, 0, 0, sw, sh, 0, 0, 0);

        int n = 3;
        for (int i=0;i<4;i++)
        {
            a[i].x = figures[n][i] % 2;
            a[i].y = figures[n][i] / 2;
        }

       for (int i=0;i<4;i++)
        {
            al_draw_bitmap_region(tile, 0, 0, a[i].x*18,a[i].y*18, 0, 0, 0);
        }

        al_flip_display();
        al_rest(0.001);//pauza
    }
    return 0;
}
